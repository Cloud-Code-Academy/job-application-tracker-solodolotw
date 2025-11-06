public with sharing class JoobleIntegrationCalloutMockGenerator implements HttpCalloutMock {
    public static String JOOBLE_JOB_PAYLOAD = '{"jobs": [{"title": "Salesforce Developer", "company": "Tech Company Inc", "salary": "$150k - $200k", "snippet": "We are looking for a talented Salesforce Developer", "link": "https://example.com/job1"}]}';
    public static String JOOBLE_JOB_PAYLOAD_NULL_SALARY = '{"jobs": [{"title": "Junior Developer", "company": "Startup Inc", "salary": null, "snippet": "Entry level position", "link": "https://example.com/job2"}]}';
    public static String JOOBLE_JOB_PAYLOAD_MULTIPLE = '{"jobs": [{"title": "Salesforce Developer", "company": "Tech Company Inc", "salary": "$150k - $200k", "snippet": "We are looking for a talented Salesforce Developer", "link": "https://example.com/job1"}, {"title": "Senior Salesforce Developer", "company": "Another Tech Corp", "salary": "$200k - $250k", "snippet": "Seeking experienced Salesforce professional", "link": "https://example.com/job2"}]}';

    private Integer statusCode;
    private Boolean nullSalary;
    private Boolean multipleJobs;

    public JoobleIntegrationCalloutMockGenerator() {
        this.statusCode = 200;
        this.nullSalary = false;
        this.multipleJobs = false;
    }

    public JoobleIntegrationCalloutMockGenerator(Integer statusCode) {
        this.statusCode = statusCode;
        this.nullSalary = false;
        this.multipleJobs = false;
    }

    public JoobleIntegrationCalloutMockGenerator(Integer statusCode, Boolean nullSalary) {
        this.statusCode = statusCode;
        this.nullSalary = nullSalary;
        this.multipleJobs = false;
    }

    public JoobleIntegrationCalloutMockGenerator(Integer statusCode, Boolean nullSalary, Boolean multipleJobs) {
        this.statusCode = statusCode;
        this.nullSalary = nullSalary;
        this.multipleJobs = multipleJobs;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);

        if (statusCode == 200) {
            if (multipleJobs) {
                res.setBody(JOOBLE_JOB_PAYLOAD_MULTIPLE);
            } else if (nullSalary) {
                res.setBody(JOOBLE_JOB_PAYLOAD_NULL_SALARY);
            } else {
                res.setBody(JOOBLE_JOB_PAYLOAD);
            }
        } else {
            res.setBody('{"error": "Bad Request"}');
        }

        return res;
    }
}