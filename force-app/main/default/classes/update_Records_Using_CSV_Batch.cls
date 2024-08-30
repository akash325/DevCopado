public with sharing class update_Records_Using_CSV_Batch implements database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc){
        // 1 million records ---- 2000 records to execute
        return Database.getQueryLocator('SELECT ID, Name FROM Account');
    }
    
    public void execute(Database.BatchableContext bc, List<Account> subListFromStartMethod){
        //logic to process 2000 records
        for(Account acc : subListFromStartMethod){
            acc.Name = 'Batch Updated - ' + acc.Name;
        }
        Update subListFromStartMethod;
    }

    public void finish(Database.BatchableContext bc){
        //post process logic
        System.debug(' @@Batch job completed');
    }
}