/**
 * @author Altimetrik
 * @description
 *  started on 06/06/2018
 *  This class test EventSchedullingListCtrl class
 **/
@isTest
public class EventSchedullingListCtrl_Test {

    /*
    Description: Test Class Setup method.
    */
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

    /*
    Description: Check getSelectedRecords() and getRecordsAll() for Contact object.
    */
    @isTest
    private static void test_getContactRecords() {
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 10];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(contactList);
        ssc.setSelected([SELECT Id FROM Contact LIMIT 5]);

        Test.startTest();
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl(ssc);
        String selectedList = eslc.getSelectedRecords();
        List<sObject> selected = (List<sObject>)System.JSON.deserialize(selectedList, List<sObject>.class);                       
        List<sObject> allRecords = eslc.getRecordsAll();
        Test.stopTest();
        System.assertEquals(5, selected.size());
        System.assertEquals(Contact.sObjectType, selected[0].getSObjectType());
        System.assertEquals(10, allRecords.size());
        System.assertEquals(Contact.sObjectType, allRecords.getSObjectType());
    }

    /*
    Description: Check getSelectedRecord() when there's no selected Contact Records.
    */
    @isTest
    private static void test_getContactRecordsNotSelected() {
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 10];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(contactList);
        ssc.setSelected(new List<Contact>());

        Test.startTest();
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl(ssc);
        String selectedList = eslc.getSelectedRecords();
        List<sObject> selected = (List<sObject>)System.JSON.deserialize(selectedList, List<sObject>.class);                       
        List<sObject> allRecords = eslc.getRecordsAll();
        Test.stopTest();
        System.assertEquals(0, selected.size());
        System.assertEquals(10, allRecords.size());
        System.assertEquals(Contact.sObjectType, allRecords.getSObjectType());
    }

    /*
    Description: Check getSelectedRecords() and getRecordsAll() for Lead object.
    */
    @isTest
    private static void test_getLeadRecords() {
        List<Lead> leadList = [SELECT Id FROM Lead LIMIT 10];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(leadList);
        ssc.setSelected([SELECT Id FROM Lead LIMIT 5]);

        Test.startTest();
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl(ssc);
        String selectedList = eslc.getSelectedRecords();
        List<sObject> selected = (List<sObject>)System.JSON.deserialize(selectedList, List<sObject>.class);                       
        List<sObject> allRecords = eslc.getRecordsAll();
        Test.stopTest();
        System.assertEquals(5, selected.size());
        System.assertEquals(Lead.sObjectType, selected[0].getSObjectType());
        System.assertEquals(10, allRecords.size());
        System.assertEquals(Lead.sObjectType, allRecords.getSObjectType());
    }

    /*
    Description: Check getSelectedRecord() when there's no selected Lead Records.
    */
    @isTest
    private static void test_getLeadRecordsNotSelected() {
        List<Lead> leadList = [SELECT Id FROM Lead LIMIT 10];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(leadList);
        ssc.setSelected(new List<Lead>());

        Test.startTest();
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl(ssc);
        String selectedList = eslc.getSelectedRecords();
        List<sObject> selected = (List<sObject>)System.JSON.deserialize(selectedList, List<sObject>.class);                       
        List<sObject> allRecords = eslc.getRecordsAll();
        Test.stopTest();
        System.assertEquals(0, selected.size());
        System.assertEquals(10, allRecords.size());
        System.assertEquals(Lead.sObjectType, allRecords.getSObjectType());
    }
    
    /*
    Description: Check getSelectedRecords() and getRecordsAll() for Account object.
    */ 
    @isTest
    private static void test_getAccountRecords() {
        List<Account> accountList = [SELECT Id FROM Account LIMIT 10];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accountList);
        ssc.setSelected([SELECT Id FROM Account LIMIT 5]);

        Test.startTest();
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl(ssc);
        String selectedList = eslc.getSelectedRecords();
        List<sObject> selected = (List<sObject>)System.JSON.deserialize(selectedList, List<sObject>.class);                       
        List<sObject> allRecords = eslc.getRecordsAll();
        Test.stopTest();
        System.assertEquals(5, selected.size());
        System.assertEquals(Account.sObjectType, selected[0].getSObjectType());
        System.assertEquals(10, allRecords.size());
        System.assertEquals(Account.sObjectType, allRecords.getSObjectType());
    }

    /*
    Description: Check getSelectedRecord() when there's no selected Account Records.
    */
    @isTest
    private static void test_getAccountNotSelectedRecords() {
        List<Account> accountList = [SELECT Id FROM Account LIMIT 10];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accountList);
        ssc.setSelected(new List<Account>());

        Test.startTest();
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl(ssc);
        String selectedList = eslc.getSelectedRecords();
        List<sObject> selected = (List<sObject>)System.JSON.deserialize(selectedList, List<sObject>.class);                       
        List<sObject> allRecords = eslc.getRecordsAll();
        Test.stopTest();
        System.assertEquals(0, selected.size());
        System.assertEquals(10, allRecords.size());
        System.assertEquals(Account.sObjectType, allRecords.getSObjectType());
    }
    /*
    Description: Check EventSchedullingListCtrl Constructor initPrefix assignment.
    */
    @isTest
    private static void test_EventSchedullingListCtrlEmpty() {
        EventSchedullingListCtrl eslc = new EventSchedullingListCtrl();
        System.assertEquals(EventSchedullingListCtrl.getCurrentNamespace(), eslc.currentPrefix);
    }
}