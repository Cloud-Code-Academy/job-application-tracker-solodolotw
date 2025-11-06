public with sharing class JoobleQueueable implements Queueable{

    private String keywords;
    private String location;
    private Integer salary;
    private String resultonpage;
    private String page;
    private String datecreatefrom;
    
    public JoobleQueueable(String keywords, 
                           String location, 
                           Integer salary, 
                           String resultonpage, 
                           String page, 
                           String datecreatefrom) {

        this.keywords = keywords;
        this.location = location;
        this.salary = salary;
        this.resultonpage = resultonpage;
        this.page = page;
        this.datecreatefrom = datecreatefrom;

    }
    
    public void execute(QueueableContext qc) {
        JoobleIntegration.getJoobleJobPosting(keywords, location, salary, resultonpage, page, datecreatefrom);
    }
}