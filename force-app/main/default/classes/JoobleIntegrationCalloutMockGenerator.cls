@isTest
public class JoobleIntegrationCalloutMockGenerator implements HttpCalloutMock {

    public static String DUMMY_JSON_USER_PAYLOAD ='{"jobs": [{"title": "Salesforce Developer", "location": "Boulder, CO", "salary": "$150000 - $200000", "source": "Jooble", "type": "Full-time", "link": "https://example.com/job/123", "company": "Tech Co"}]}';
    
    public HttpResponse respond(HttpRequest request) {

        //Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //Successful status code
        response.setStatusCode(200);
        //Set repsonse body
        response.setBody(DUMMY_JSON_USER_PAYLOAD);
        return response;
    }
}