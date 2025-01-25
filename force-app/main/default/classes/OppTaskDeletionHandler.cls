public with sharing class OppTaskDeletionHandler {
   public static void trgMethod(List<Opportunity> oldOppList){
       Set<Id> accIds=new Set<Id>();
       Map<Id,Opportunity> oppMap=new Map<Id,Opportunity>();
       List<Task> taskToUpdate=new List<Task>();
       List<Task> taskToDelete=new List<Task>();

       Map<Id,Opportunity> oppAccountIdMap=new Map<Id,Opportunity>();
       if(!oldOppList.isEmpty()){
             for(Opportunity opp: oldOppList){
                 if(opp.AccountId !=null){
                    accIds.add(opp.AccountId);
                    oppMap.put(opp.Id,opp);
                 }
             }
       }

       if(!oppMap.isEmpty()){
          List<Task> taskList=[Select Id,WhatId from Task where WhatId IN :oppMap.keyset()];

          List<Opportunity> oppList=[Select Id,IsClosed,AccountId from Opportunity where AccountId IN :accIds AND Id NOT IN :oppMap.keySet() AND IsClosed=false];

          if(!oppList.isEmpty()){
              for(Opportunity opp : oppList){
                   oppAccountIdMap.put(opp.AccountId,opp);
              }
          }
           
          if(!taskList.isEmpty()){
            for(Task ts : taskList){
                if(oppMap.containsKey(ts.WhatId)){
                     Opportunity oldOpp=oppMap.get(ts.WhatId);
                     if(oppAccountIdMap.containsKey(oldOpp.AccountId)){
                           ts.WhatId=oppAccountIdMap.get(oldOpp.AccountId).Id;
                           taskToUpdate.add(ts);
                     }
                }else{
                    taskToDelete.add(ts);
                }
            }
                
          }
       }

       if(!taskToUpdate.isEmpty()){
        update taskToUpdate;
       }

       if(!taskToDelete.isEmpty()){
          delete taskToDelete;
       }
   }
}