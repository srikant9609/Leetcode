public with sharing class UpdateAccountDescripTriggerHandler {
   public static void trgMethod(List<Contact> newConList,Map<Id,Contact> oldConMap){
       Contact oldCon=new Contact();
       Set<Id> accIds=new Set<Id>();
       List<Account> accountUpdate=new List<Account>();
        if(!newConList.isEmpty()){
              for(Contact con : newConList){
                    if(oldConMap !=null){
                        oldCon=oldConMap.get(con.Id);
                        if(oldCon.AccountId != con.AccountId){
                            accIds.add(oldCon.AccountId);
                            accIds.add(con.AccountId);
                        }
                        else{
                            accIds.add(con.AccountId);
                        }
                    }
                    else{
                        accIds.add(con.AccountId);
                    }
              }
            }

            if(oldConMap !=null && newConList==null ){
                   for(Contact con: oldConMap.values()){
                    accIds.add(con.AccountId);
                   }
            }
              if(!accIds.isEmpty()){
                   for(Account acc : [Select Id,Description,(Select Id,Name,CreatedDate from Contacts) from Account where Id IN: accIds]){
                            if(!acc.Contacts.isEmpty()){
                                String temDesc='Associated Contacts as below>>>' +'\n';
                                for(Contact con : acc.Contacts){
                                    temDesc+='Contact Name ->'+con.Name + 'Created On '+con.CreatedDate +'\n';
                                }
                                acc.Description=temDesc;
                            }
                            accountUpdate.add(acc);

                   }
              }
        

        if(!accountUpdate.isEmpty()){
            update accountUpdate;
        }
   }
}