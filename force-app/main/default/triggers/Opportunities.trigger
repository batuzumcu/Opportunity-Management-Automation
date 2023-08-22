trigger Opportunities on Opportunity (after insert, after update) {
    List<Task> taskList = new List<Task>();
    Set<Id> oppIdsToProcess = new Set<Id>();
    Set<Id> accountIdsToCheck = new Set<Id>();

    for (Opportunity opp : Trigger.new) {
        if (opp.StageName == 'Closed Won' && (Trigger.isInsert || (Trigger.oldMap.get(opp.Id).StageName != 'Closed Won'))) {
            oppIdsToProcess.add(opp.Id);
            accountIdsToCheck.add(opp.AccountId);
        }
    }

    if (oppIdsToProcess.isEmpty()) return;

    Map<Id, Id> primaryContact = new Map<Id, Id>();
    Map<Id, Contact> latestContactsByOpp = new Map<Id, Contact>();
    Map<Id, Contact> latestContactsByAccount = new Map<Id, Contact>();

    // Primary contacts of the opportunities
    for (OpportunityContactRole ocr : [SELECT OpportunityId, ContactId 
                                        FROM OpportunityContactRole 
                                        WHERE IsPrimary = TRUE AND OpportunityId IN :oppIdsToProcess]) {
        primaryContact.put(ocr.OpportunityId, ocr.ContactId);
    }

    // Remove accounts that have primary contacts
    accountIdsToCheck.removeAll(primaryContact.keySet());


    if(primaryContact.isEmpty()){ 
        //if no primary contact on opp get latest contact on opp  
        for (OpportunityContactRole ocr : [SELECT OpportunityId, ContactId, Contact.CreatedDate 
                                            FROM OpportunityContactRole 
                                            WHERE OpportunityId IN :oppIdsToProcess 
                                            ORDER BY Contact.CreatedDate DESC]) {
            if (!primaryContact.containsKey(ocr.OpportunityId) && !latestContactsByOpp.containsKey(ocr.OpportunityId)) {
                latestContactsByOpp.put(ocr.OpportunityId, ocr.Contact);
            }
        }
        if(latestContactsByOpp.isEmpty()){
            // if no contact on opp get latest contact on opp's acc 
            for (Contact c : [SELECT Id, AccountId 
                            FROM Contact 
                            WHERE AccountId IN :accountIdsToCheck 
                            ORDER BY CreatedDate DESC LIMIT 10000]) {
                if (!latestContactsByAccount.containsKey(c.AccountId)) {
                    latestContactsByAccount.put(c.AccountId, c);
                }
            }
        }
    }
    
    // Create tasks
    for (Id oppId : oppIdsToProcess) {
        Opportunity currentOpp = Trigger.newMap.get(oppId);
        Task reminderTask = new Task(
            Subject = 'Reminder',
            Priority = 'High',
            Status = 'Open',
            Description = 'Please validate the details of this closed won opportunity.',
            WhatId = oppId,
            OwnerId = currentOpp.OwnerId,
            ActivityDate = Date.today().addDays(3)
        );

        if (primaryContact.containsKey(oppId)) {
            reminderTask.WhoId = primaryContact.get(oppId);
        } else if (latestContactsByOpp.containsKey(oppId)) {
            reminderTask.WhoId = latestContactsByOpp.get(oppId).Id;
        } else {
            reminderTask.WhoId = latestContactsByAccount.get(currentOpp.AccountId)?.Id;
        }

        taskList.add(reminderTask);
    }

    insert taskList;
}
