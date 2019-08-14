trigger DeDupe on Account (after insert) {
    for( Account a : Trigger.new ) {
        Case c = Case();
        c.OwnerId = 'hardcoded userid for intern';
        c.Subject = 'Dedupe this account';
        c.AccountId = a.Id;
        insert c;
    }
}