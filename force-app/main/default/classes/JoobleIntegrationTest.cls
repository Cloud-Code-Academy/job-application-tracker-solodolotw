@isTest
public with sharing class JoobleIntegrationTest {

    @isTest
    public static void testGetJoobleJobPosting_success() {

        Test.setMock(HttpCalloutMock.class, new JoobleIntegrationCalloutMockGenerator());

        Test.startTest();
        JoobleIntegration.getJoobleJobPosting('Salesforce Developer', 'Phoenix, AZ', 100000, '20', '1', '2025-06-01');
        Test.stopTest();

        List<Job_Application__c> createdApps = [
            SELECT Id, Job_Title__c, Company_Name__c, Salary__c, Description__c, Job_Posting_URL__c
            FROM Job_Application__c
            WHERE Job_Title__c = 'Salesforce Developer'
        ];

        System.assertEquals(1, createdApps.size(), 'One job application should be created');
        System.assertEquals('Salesforce Developer', createdApps[0].Job_Title__c, 'Job title should match');
        System.assertEquals('Tech Co', createdApps[0].Company_Name__c, 'Company name should match');
    }
}