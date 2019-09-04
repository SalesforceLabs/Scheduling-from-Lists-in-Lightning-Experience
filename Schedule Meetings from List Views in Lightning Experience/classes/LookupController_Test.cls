@isTest
public class LookupController_Test {
@testSetup
    private static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i<10; i++) {
            accounts.add(new Account(Name = 'Test Account' + i));
            contacts.add(new Contact(LastName = 'Test Contact ' + i));
            leads.add(new Lead(LastName = 'Test Lead ' + i, Company = 'Test Company ' + i));
        }
        insert accounts;
        insert contacts;
        insert leads;
        
        System.assertEquals(10, accounts.size());
        System.assertEquals(10, contacts.size());
        System.assertEquals(10, leads.size());
    }

    @isTest
    private static void test_getContactRecords() {

        String objectAPIName = 'Contact';
        String searchText = 'Test Contact1';
        List<String> whereClause = new List<String>();
        List<String> extrafields =  new List<String>();
        extrafields.add('Name');
        extrafields.add('Account.Name');
        
    
        Test.startTest();
               
        String selectedList = LookupController.search(objectAPIName, searchText, whereClause, extrafields);
        List<List<sObject>> selected = (List<List<sObject>>)System.JSON.deserialize(selectedList, List<List<sObject>>.class);                       
        System.debug(selected[0]);
        Test.stopTest();

        System.assertEquals(1, selected.size());
        
        
    }
}