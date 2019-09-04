/**
* @author Altimetrik
* @description
* started on June 2018
* This class its responsible of the interaction with lightning components
**/

public with sharing class LookupController {

   /* Method to query records using SOSL*/
    @AuraEnabled
    public static String search(String objectAPIName, String searchText,
            List<String> whereClause, List<String> extrafields){
        String returnedStirng;
        Schema.DescribeSObjectResult describeSObjectResultObj = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();

        if(describeSObjectResultObj.isAccessible()){
            extrafields = notAllowedFields(extrafields,describeSObjectResultObj);
            objectAPIName = String.escapeSingleQuotes(objectAPIName);
            searchText = String.escapeSingleQuotes(searchText);
            String searchQuery = 'FIND \'' + searchText + '*\' IN ALL FIELDS RETURNING ' + objectAPIName + '(Id' ;
            if(!extrafields.isEmpty()){
                searchQuery = searchQuery + ',' + String.join(extrafields, ',') ;
            }
            if(!whereClause.isEmpty()){
                searchQuery = searchQuery + ' WHERE ' ;
                searchQuery = searchQuery + String.join(whereClause, 'AND') ;
            }
            searchQuery = searchQuery + ' LIMIT 5 ) ';
            
            returnedStirng = JSON.serializePretty(search.query(searchQuery));
        }

        return returnedStirng ;
    }

    /* Method to query records using SOQL*/
    @AuraEnabled
    public static List<SObject> getRecentlyViewed(
            String objectAPIName,
            List<String> whereClause,
            List<String> extrafields){
        String returnedStirng;
        List<SObject> retunredList = new List<SObject>();
        Schema.DescribeSObjectResult describeSObjectResultObj = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();

        if(describeSObjectResultObj.isAccessible()){
            extrafields = notAllowedFields(extrafields,describeSObjectResultObj);
            String searchQuery = 'SELECT Id';
            if(!extrafields.isEmpty()){
                searchQuery = searchQuery + ',' + String.join(extrafields, ',') ;
            }
            searchQuery = searchQuery + ' FROM ' + objectAPIName + ' WHERE LastViewedDate != NULL ';
            if(!whereClause.isEmpty()){
                searchQuery = searchQuery + ' AND ' ;
                searchQuery = searchQuery + String.join(whereClause, 'AND') ;
            }
            searchQuery = searchQuery + ' ORDER BY LastViewedDate DESC LIMIT 5' ;
            List<SObject> objectList =  new List<SObject>();
            retunredList = Database.query(searchQuery);
            
        }
        return retunredList;
    
    }

    @AuraEnabled
    public static Map<String,String> filterObjectRestrictions(Map<String,String> maps){
 
        for (String key : maps.keySet()){
            if (Schema.getGlobalDescribe().get(key)!=null){
                if(!Schema.getGlobalDescribe().get(key).getDescribe().isAccessible()){
                    maps.remove(key);
                }
           }
          
        }
        return maps;
      
    }

    private static List<String> notAllowedFields(List<String> searchFields,Schema.DescribeSObjectResult describeSObjectResultObj ){
        
        List<String> returnedList = new List<String>();
        Map<String,SObjectField> fields = describeSObjectResultObj.fields.getMap();
        
        String[] fieldQuery;

        for (String stringField : searchFields){
            fieldQuery = stringField.split('\\.');
            if (fieldQuery.size()==1){
                SObjectField field = fields.get(stringField);
                if(field != null && field.getDescribe().isAccessible()){
                    returnedList.add(stringField);
                }
            }else {              
               if(hasLookUpPermissions(fieldQuery,fields)){
                   returnedList.add(stringField);
               }
            }
        }

        return returnedList;
    }

    private static boolean hasLookUpPermissions(String[] fieldsplitted,Map<String,SObjectField> fields){
        boolean permissions = false;
        String lookUpfield = fieldsplitted[0]+'Id';
        Schema.DescribeSObjectResult describeSObjectResultObjRelated= Schema.getGlobalDescribe().get(fieldsplitted[0]).getDescribe();

        if(fields.get(lookUpfield).getDescribe().isAccessible()){
            if(describeSObjectResultObjRelated != null 
                 && describeSObjectResultObjRelated.isAccessible() 
                 && describeSObjectResultObjRelated.fields.getMap().get(fieldsplitted[1]) != null
                 && describeSObjectResultObjRelated.fields.getMap().get(fieldsplitted[1]).getDescribe().isAccessible()){
                     permissions = true;
            }

        }
        return permissions;

    }
}