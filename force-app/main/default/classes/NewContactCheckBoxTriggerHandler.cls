public with sharing class NewContactCheckBoxTriggerHandler {
    public static void trgMethod(List<Contact> newConList){
        Set<Id> accIds=new Set<Id>();
        Map<Id,Contact> conMap=new Map<Id,Contact>();
        List<Contact> existingconList=new List<Contact>();
        List<Contact> conListToUpdate=new List<Contact>();
        if(!newConList.isEmpty()){
            for(Contact con : newConList){

                if(con.AccountId !=null){
                    accIds.add(con.AccountId);
                }

            }
        }

        if(!accIds.isEmpty()){
          existingconList = [Select Id,Name,AccountId,CreatedDate,NewContact__c from Contact where AccountId IN : accIds order by CreatedDate DESC];
        }
        if(!existingconList.isEmpty()){
            for(Contact con : existingconList){
                if(!conMap.containsKey(con.AccountId)){
                    conMap.put(con.AccountId,con);
                }
            }
            for(Contact con : existingconList){
                if(con.Id == conMap.get(con.AccountId).Id && con.NewContact__c == false){
                    con.NewContact__c=true;
                }
                else{
                    if(con.NewContact__c == true && con.Id != conMap.get(con.AccountId).Id){
                        con.NewContact__c = false;
                    }
                } 
                conListToUpdate.add(con);
            }
        }

        if(!conListToUpdate.isEmpty()){
            update conListToUpdate;
        }
    }
}