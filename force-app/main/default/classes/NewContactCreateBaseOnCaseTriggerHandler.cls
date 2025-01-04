public with sharing class NewContactCreateBaseOnCaseTriggerHandler {
    public static void trgMethod(List<Case> newCaseList){
        Set<String> emailset=new Set<String>();
        Map<String,Id> conEmailMap=new Map<String,Id>();
        Map<String,Id> conToCaseMap=new Map<String,Id>();
        List<Contact> conListToInsert=new List<Contact>();
        if(!newCaseList.isEmpty()){
            for(Case cs : newCaseList){
                if(cs.SuppliedEmail !=null){
                    emailset.add(cs.SuppliedEmail);
                }
            }
        }

        if(!emailset.isEmpty()){
            for(Contact con :[Select Id,Email from Contact where Email IN :emailset]){
                  if(!conEmailMap.containsKey(con.Email)){
                    conEmailMap.put(con.Email,con.Id);
                  }
            }
        }

        if(!newCaseList.isEmpty()){
            for(Case c: newCaseList){
                if(conEmailMap.containsKey(c.SuppliedEmail)){
                    Id existingContactId=conEmailMap.get(c.SuppliedEmail);
                     conToCaseMap.put(c.SuppliedEmail,existingContactId);
                }
                else{
                    Contact con=new Contact();
                    con.FirstName='Case Email '+c.SuppliedEmail;
                    con.LastName='Contact Last Name';
                    con.Email=c.SuppliedEmail;
                    conListToInsert.add(con);
                }
            }
        }

        if(!conListToInsert.isEmpty()){
            insert conListToInsert;

            for(Contact con : conListToInsert){
                if(con.Email !=null){
                    conToCaseMap.put(con.Email,con.Id);
                }
            }
        }

        for(Case c : newCaseList){
           if(conToCaseMap.containsKey(c.SuppliedEmail)){
               c.ContactId=conToCaseMap.get(c.SuppliedEmail);
           }
        }

    }
}