public class CreateObject {
    
    public static void create(Id recordId){
    SObject obj= recordId.getSObjectType().newSObject(recordId);
        obj.put('Name','Srisri');
        System.debug(obj);  
    }
    
    public static void  getObjectInfo(){
        Schema.DescribeSObjectResult res = Account.SObjectType.getDescribe();
      List<Schema.ChildRelationship> relations=  res.getChildRelationships();
      List<RecordTypeInfo> recInfos=  res.getRecordTypeInfos();
        //otherway
      Map<String,Schema.SObjectType> allObjs=  Schema.getGlobalDescribe();
     Schema.DescribeSObjectResult res1 = allObjs.get('Account').getDescribe();
        
      Map<String,SObjectField> relFields=  res.fields.getMap();
      // OR  field information
      
    Schema.DescribeFieldResult fieres=  Account.Type.getDescribe(); 
        
        // picklistInfo
      List<Schema.PicklistEntry>  pickval= Account.Rating.getDescribe().getPicklistValues();
        for(Schema.ChildRelationship rel :relations){
            System.debug('Child sobject Name'+rel.getChildSObject());
            System.debug('Field Name on Child'+rel.getField());
            System.debug('RelationshipName'+rel.getRelationshipName());
            System.debug('Is Cascade Delete'+rel.isCascadeDelete());
            System.debug('is Restricted Delete'+rel.isRestrictedDelete());
        }
        
    }

}