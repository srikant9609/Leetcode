trigger OppTaskDeletionTrigger on Opportunity (before delete) {

    if(trigger.isBefore && trigger.isDelete){
        OppTaskDeletionHandler.trgMethod(trigger.old);
    }

}