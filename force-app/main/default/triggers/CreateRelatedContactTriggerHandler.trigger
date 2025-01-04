trigger CreateRelatedContactTriggerHandler on Account (after insert,after update) {
//CreateContact__c
List<Contact> cons=new List<Contact>();
List<Id> accIds=new List<Id>();
    if(Trigger.isAfter){
        if(Trigger.isUpdate || Trigger.isInsert){
            if(!Trigger.new.isEmpty()){
                for(Account acc: Trigger.new){
                    if(Trigger.oldMap !=null){
                       Account oldAcc=Trigger.oldMap.get(acc.Id);
                        if(acc.CreateContact__c == true && oldAcc.CreateContact__c == false){
                            /*Contact con=new Contact();
                            con.LastName='Contact';
                            con.FirstName=acc.Name;
                            con.AccountId=acc.Id;
                            cons.add(con);*/
                            accIds.add(acc.Id);
                        }
                    }else{
                        if(acc.CreateContact__c==true){
                            accIds.add(acc.Id);
                        }
                    }
                  
                }
            }
         
            if(!accIds.isEmpty()){
                Integer i=0;
                for(Id acId: accIds){
                    Contact con=new Contact();
                    con.LastName='Contact'+i;
                    con.AccountId=acId;
                    cons.add(con);
                    i++;
                }
            }



            
        }
    }

    if(!cons.isEmpty()){
        insert cons;
    }

}