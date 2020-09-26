trigger ServiceAppointmentTrigger on ServiceAppointment (Before Insert, Before Update) {

if(trigger.IsInsert){
    for(ServiceAppointment t : trigger.new){
    	
	//migration complete so don't need this
	//if(t.SFPS_FSMT_DataSource__c<>'CKSW_BASE__Service__c'){
    	
        //system.debug('CRTDEBUG:' + '=' + t.ParentRecord);

        //if(t.ParentRecordType=='WorkOrder'){	// does this even hit since ParentRecordType==null in the trigger insert?
    	WorkOrder wo = null;
    	//wo = [SELECT AccountId, City, ContactId, Phone__c, EMail_Address__c, Other_Phone__c, Id FROM WorkOrder WHERE Id = :t.ParentRecordId LIMIT 1];

      // where id = :ApexPages.currentPage().getParameters().get('id')];
      List<WorkOrder> wos = [SELECT AccountId, City, ContactId, Phone__c, EMail_Address__c, Other_Phone__c, Id FROM WorkOrder WHERE Id = :t.ParentRecordId LIMIT 1];
      if(wos.size() > 0) wo = wos[0];

 
	    string AccountName = '';
	    string WorkTypeName = '';
        string ContactAccountId = '';
		string CityName = '';
		if(wo!=null) {
        	//t.EMail_Address__c=wo.EMail_Address__c;	//comes from contact instead
        	t.Other_Phone__c=wo.Other_Phone__c;
        	t.Phone__c=wo.Phone__c;
        	t.ContactId = wo.ContactId;
	        if (t.ContactId != null) ContactAccountId = [SELECT AccountId FROM Contact WHERE Id=:t.ContactId LIMIT 1].AccountId;
			if(wo.AccountId==null && t.ContactId != null && ContactAccountId != null){wo.AccountId = ContactAccountId;update wo;}
		    AccountName = [SELECT Name FROM Account WHERE Id=:wo.AccountId LIMIT 1].Name;
		    CityName = wo.City;
        }
        
        // CRT 2018-05-16
        if(t.ReportingResource__c<>null){
        ServiceResource sr = [Select Id, RelatedRecordId from ServiceResource where Id=:t.ReportingResource__c limit 1];
        t.taskuserid__c = sr.RelatedRecordId;
        t.NotificationUser__c = sr.RelatedRecordId;//[SELECT Id from User Where Id=:t.taskuserid__c LIMIT 1].Id;
        }
        
        /* CRT 2019-07-16: WorkServiceType
        system.debug('CRTdebug:' + t);
        if(t.WorkType__c!=null) WorkTypeName = [SELECT Name FROM WorkType WHERE Id=:t.WorkType__c LIMIT 1].Name;
    	//t.FSL__GanttLabel__c =  t.City + ' - ' + t.WorkType__r.Name + ' - ' + t.Account.Name + ' - ' + t.Species__c;
    	t.FSL__GanttLabel__c =  CityName + ' - ' + WorkTypeName + ' - ' + AccountName + ' - ' + t.Species__c; */
    	t.FSL__GanttLabel__c =  CityName + ' - ' + t.ServiceType__c + ' - ' + AccountName + ' - ' + t.Species__c;
    	
    	
    	// CRT 2019-07-16: WorkServiceType
    	//t.ServiceType__c = WorkTypeName;	// CRT 2019-04-21

	//}
	}
}

// CRT 2018-05-16
if(trigger.IsUpdate){
    for(ServiceAppointment t : trigger.new){
	system.debug('CRTdebug:Update:' + t);
    	
    // CRT 2018-09-07: Check and ensure fields are set properly on update 
    ServiceResource sr = null;
    if (t.ReportingResource__c<>null) sr=[Select Id, RelatedRecordId from ServiceResource where Id=:t.ReportingResource__c limit 1];
    if (sr <> null) {        
    	t.taskuserid__c = sr.RelatedRecordId;
        t.NotificationUser__c = sr.RelatedRecordId;
    }

	/* CRT 2019-07-16: WorkServiceType
	// CRT 2019-04-21
    if(t.ServiceType__c==null){
    	if(t.WorkType__c!=null) t.ServiceType__c = [SELECT Name FROM WorkType WHERE Id=:t.WorkType__c LIMIT 1].Name;
    }
    */
        
	//migration complete so don't need this
	//if(t.SFPS_FSMT_DataSource__c<>'CKSW_BASE__Service__c' && t.TaskUserId__c==null && t.ReportingResource__c<>null){
	if( t.TaskUserId__c==null && t.ReportingResource__c<>null){
        sr = [Select Id, RelatedRecordId from ServiceResource where Id=:t.ReportingResource__c limit 1];
        t.taskuserid__c = sr.RelatedRecordId;
        t.NotificationUser__c = sr.RelatedRecordId;
	}else if (t.NotificationUser__c == null && t.TaskUserId__c!=null){t.NotificationUser__c = t.TaskUserId__c;}
	}
}


}