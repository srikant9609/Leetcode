trigger NewContactCheckBoxTrigger on Contact (after insert) {

    if(trigger.IsAfter && trigger.IsInsert){
        NewContactCheckBoxTriggerHandler.trgMethod(trigger.new);
    }

}