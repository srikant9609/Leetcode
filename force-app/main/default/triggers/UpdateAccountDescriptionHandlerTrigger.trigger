trigger UpdateAccountDescriptionHandlerTrigger on Contact (after insert,after update,after delete,after undelete) {

    if(Trigger.IsAfter && (Trigger.isInsert || Trigger.isUndelete)){
        UpdateAccountDescripTriggerHandler.trgMethod(trigger.new,null);
    }
    if(Trigger.IsAfter && Trigger.isUpdate){
        UpdateAccountDescripTriggerHandler.trgMethod(trigger.new,trigger.oldMap);
    }
    if(Trigger.IsAfter &&  Trigger.isDelete){
        UpdateAccountDescripTriggerHandler.trgMethod(null,trigger.oldMap);
    }

}
