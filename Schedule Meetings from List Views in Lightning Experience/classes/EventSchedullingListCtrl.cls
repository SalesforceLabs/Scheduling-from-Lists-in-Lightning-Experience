/**
 * @author Altimetrik
 * @description
 *  started on 06/05/2018
 *  This class resolves list views selected records
 **/
public with sharing class EventSchedullingListCtrl {
    // Static variables
    //************************************************************************
    // Constants
    //************************************************************************
    // Properties & data members
    ApexPages.StandardSetController setCon;

    public String currentPrefix {get; private set;}
    //************************************************************************
    // Constructors
    public EventSchedullingListCtrl() {
        initPrefix();
    }
    public EventSchedullingListCtrl(ApexPages.StandardSetController controller) {
        setCon = controller;
        initPrefix();
    }
    //************************************************************************
    // Instance methods


    /*
    * @description
    *    Resolves namespace prefix
    */
    private void initPrefix() {
        currentPrefix = EventSchedullingListCtrl.getCurrentNamespace();
    }


   /*
    * @description
    *    Logic to resolve namespace prefix
    * @return
    *    String with namespace prefix
    */
    public static String getCurrentNamespace() {
        String prefix = EventSchedullingListCtrl.class.getName().substringBefore('EventSchedullingListCtrl');
        prefix = String.isBlank(prefix) ? 'c' : prefix.substringBefore('.');
        return prefix;
    }



    /*
    * @description
    *   Returns the selected Record from ApexPages.StandardSetController.
    * @params
    *   DATA_TYPE PARAM_NAME PARAM_USED_FOR
    * @return 
    *   List<sObject>
    */
    //public DATA_TYPE some_method(DATA_TYPE, PARAM_NAME){}
    public String getSelectedRecords() {
		return JSON.serialize(setCon.getSelected());
    }
    
    /*
    * @description
    *   Returns all the Records that StandardSetController holds
    * @params
    *   DATA_TYPE PARAM_NAME PARAM_USED_FOR
    * @return 
    *   List<sObject>
    */
    public List<sObject> getRecordsAll() {
        return setCon.getRecords();
    }
    
    //************************************************************************
    // Static methods

    /*
    * @description
    *   WHAT_THE_METHOD_DOES
    * @params
    *   DATA_TYPE PARAM_NAME PARAM_USED_FOR
    * @return 
    *   DATA_TYPE 
    */
    //public static DATA_TYPE some_method(DATA_TYPE, PARAM_NAME){}

    //************************************************************************
    // Inner classes

}