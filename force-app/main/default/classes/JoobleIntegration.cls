public with sharing class JoobleIntegration {
    public static void getJoobleJobPosting(
        String keywords,
        String location,
        Integer salary,
        String resultonpage,
        String page,
        String datecreatefrom
    ) {
        
        String key = 'a64f7d53-2903-4992-b6f6-2fea02c7721c';

        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://jooble.org/api/' + key);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        //Set the REQUEST BODY with the desired text values
        String requestBody = '{"keywords": "' + keywords + '", "location": "' + location + '", "salary": ' + salary + ', "resultonpage": "' + resultonpage + '", "page": "' + page + '", "datecreatefrom": "' + datecreatefrom + '"}';
        request.setBody(requestBody); 

        //Send request
		Http http = new Http();
        HttpResponse response = new Http().send(request);
        
        //Retrieve the response body
        String responseBody = response.getbody();

        //Useful debug info
        System.debug('Response Code: ' + response.getStatusCode());
        System.debug('Response Status: ' + response.getStatus());


        //If the Status Code is in the 200's, the request was successful
        if (response.getStatusCode() >= 200 && response.getStatusCode() <= 299) {
            //Create a Job Application record from the response
            List<Job_Application__c> createdApps = createJobApplications(responseBody);
            for (Job_Application__c app : createdApps) {
                System.debug('Job Application Created: ' + app.Id);
            }
        } else {
            System.debug('API Error: ' + response.getStatusCode() + ' - ' + response.getStatus() + ' - ' + responseBody);
        }
    }

    private static List<Job_Application__c> createJobApplications(String responseText) {

        //A list to hold all new Job Application records 
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>();

        //A list of 'Jobs' that we retrieve from our Map(the deserialized JSON response)
        Map<String, Object> parsedBodyResponse = (Map<String, Object>)JSON.deserializeUntyped(responseText); 
        List<Object> jobList = (List<Object>) parsedBodyResponse.get('jobs');

        //Loop through each job returned in the response
        for (Object job : jobList) {
            Map<String, Object> jobMap = (Map<String, Object>) job;
            Job_Application__c newApp = new Job_Application__c();

            //Convert the Salary text to a Decimal to prevent ---> |FATAL_ERROR|System.TypeException: Invalid decimal: $120k - $170k
            String salaryString = (String) jobMap.get('salary');

            if (salaryString != null) {
                //remove non-numerics
                salaryString = salaryString.replaceAll('[^0-9\\.]', '');

                try {
                    newApp.Salary__c = Decimal.valueOf(salaryString);                    
                } catch (Exception e) {
                    System.debug('Could not convert text to decimal: ' + newApp);
                } 
            }
            //Assign values from the JSON to new record
            newApp.Job_Title__c = (String) jobMap.get('title');
            newApp.Company_Name__c = (String) jobMap.get('company');
            newApp.Description__c = (String) jobMap.get('snippet');
            newApp.Job_Posting_URL__c = (String) jobMap.get('link');
            
            appsToInsert.add(newApp);
        }

        //If there are records to create, insert them
        if (!appsToInsert.isEmpty()) {
            insert appsToInsert;
        }

        return appsToInsert;
    }
}