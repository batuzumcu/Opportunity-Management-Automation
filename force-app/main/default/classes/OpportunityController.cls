public with sharing class OpportunityController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        return [SELECT Id, Name, StageName FROM Opportunity LIMIT 1000];
    }

    @AuraEnabled
    public static void updateOpportunityStatus(List<Id> oppIds, String status) {
        
        System.debug('Status: ' + status);

        List<Opportunity> oppsToUpdate = [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIds];
        
        System.debug('oppsToUpdate: ' + oppsToUpdate);
        
        for(Opportunity opp : oppsToUpdate) {
            if(String.isNotBlank(status)) {
                opp.StageName = status;
            } else {
                System.debug('Status is null or not selected. Skipping update for Opportunity with Id: ' + opp.Id);
            }
        }
        

        System.debug('oppsToUpdate2: ' + oppsToUpdate);

        try {
            update oppsToUpdate;
        } catch(Exception e) {
            throw new AuraHandledException('Error occurred: ' + e.getMessage());
        }
    }

    
    @AuraEnabled(cacheable=true)
    public static List<String> getOpportunityStageNames() {
        List<String> stageNames = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry p : ple) {
            stageNames.add(p.getValue());
        }

        return stageNames;
    }
}
