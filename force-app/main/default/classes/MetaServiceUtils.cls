public class MetaServiceUtils {
    
    private static final Integer METADATA_API_VERSION = 
		Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    
    public static String fetchUserSessionId(){
        String sessionId = '';
        PageReference reportPage = Page.SessionId;
        String vfContent = reportPage.getContent().toString();
        
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startP, endP);
        return sessionId;
    }
    
    public static MetadataService.MetadataPort createService(){
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = Test.isRunningTest()?UserInfo.getSessionId(): fetchUserSessionId();
        return service;
        
    }
    
    public static List<MetadataService.FileProperties> listMetadata(String typex){
        
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery genericMetadata = new MetadataService.ListMetadataQuery();
        genericMetadata.type_x = typex;
        queries.add(genericMetadata);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 50);
        for(MetadataService.FileProperties prop : fileProperties){
            System.debug(prop.fullName);
        }
        return fileProperties;
    }
    
    public static void readMetadata(){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.Profile profileDetails = (MetadataService.Profile) service.readMetadata('Profile',
                                                                new String[] { 'Admin' }).getRecords()[0];
        
        MetadataService.ProfileLoginHours loginHours = profileDetails.loginHours;
        MetadataService.ProfileLoginIpRange[] loginIpRanges = profileDetails.loginIpRanges;
        System.debug(' loginHours \n '+loginHours);
        System.debug(' loginIpRanges \n '+loginIpRanges);
        
    }
    public static MetadataService.CustomField readCustomFieldMetadata(String tpye_x){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomField customFieldInfo = (MetadataService.CustomField) service.readMetadata('CustomField',
                                                                new String[] { 'Account.AccountSource' }).getRecords()[0];
        
        System.debug(' fullName \n '+customFieldInfo.fullName);
        System.debug(' securityClassification \n  '+customFieldInfo.securityClassification);
        System.debug(' businessOwnerGroup \n '+customFieldInfo.businessOwnerGroup);
        System.debug(' businessOwnerUser \n '+customFieldInfo.businessOwnerUser);
        System.debug(' businessStatus \n '+customFieldInfo.businessStatus);
        System.debug(' complianceGroup \n '+customFieldInfo.complianceGroup);
        return customFieldInfo;
    }
    
    public static MetadataService.CustomObject readCustomObjectMetadata(String apiName){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomObject customObjectDetails = (MetadataService.CustomObject) service.readMetadata('CustomObject',
                                                                new String[] { apiName }).getRecords()[0];
        System.debug(' \n '+customObjectDetails);
        return customObjectDetails;
    }
    
    public static void readApexClassMetadata(){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.ApexClass ApexClassDetails = (MetadataService.ApexClass) service.readMetadata('ApexClass',
                                                                new String[] { 'LinkedInUtil' }).getRecords()[0];
        System.debug(' ApexClassDetails \n '+ApexClassDetails.content);
    }
    
    public static void retrieveMetadataItem() {		
		
		MetadataService.MetadataPort service = createService();				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = METADATA_API_VERSION;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
		packageType.name = 'ApexClassRetrieve'; 
		packageType.members = new String[] { 'ApexClass', 'LinkedInUtil' };
		retrieveRequest.unpackaged.types.add(packageType);
		MetadataService.AsyncResult AsyncResult = service.retrieve(retrieveRequest);
		MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.Id, true);
		if(retrieveResult.done){
			if(retrieveResult.status != 'Succeeded'){				
			}else{
				String MetaDataRetrieveZip = retrieveResult.zipFile;
                System.debug(' MetaDataRetrieveZip '+MetaDataRetrieveZip);
				AsyncResult = null;
			}
		}				
	}
    
    public static void createObject(String objectLabel, String pluralLabel, String description){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = objectLabel.replace(' ', '_')+'__c'; // Test Object => Test_Object__c
        customObject.label = objectLabel;
        customObject.description = description;
        customObject.enableActivities = true;
        customObject.enableFeeds = true;
        customObject.enableSearch = true;
        customObject.enableReports = true;
        customObject.enableFeeds = true;
        
        customObject.pluralLabel = pluralLabel;
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = objectLabel+' Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customObject } );
        handleSaveResults(results[0]);
        
    }
    
    public static void createObjectWithAN(String objectLabel, String pluralLabel, String description){
        
        MetadataService.MetadataPort service = createService();
        
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = objectLabel.replace(' ', '_')+'__c'; // Test Object => Test_Object__c
        customObject.label = objectLabel;
        customObject.description = description;
        customObject.enableActivities = true;
        customObject.enableSearch = true;
        customObject.enableReports = true;
        customObject.enableFeeds = true;
        
        customObject.pluralLabel = pluralLabel;
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'AutoNumber';
        customObject.nameField.label = objectLabel+' Record';
        customObject.nameField.displayFormat = 'UIMD-{00000}'; 
        customObject.nameField.startingNumber = 1;
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customObject } );
        handleSaveResults(results[0]);
        
    }
    
    public static void createFields(String objectApiName, String fieldLabel, Boolean required, 
                                    Boolean extenalId, Boolean unique,Boolean caseSensitive){
        
        MetadataService.MetadataPort service 	= createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName 		= objectApiName+'.'+fieldLabel.replace(' ', '_')+'__c'; // Account - Active => Account.Active__c
        customField.label 			= fieldLabel;
        customField.type_x 			= 'Text';
        customField.description 	= 'This is the field created from Custom Metadata';
        customField.inlineHelpText	= 'This is the field created from Custom Metadata';
        customField.length			= 60;
        customField.required		= required;
        customField.unique			= unique;
        customField.externalId		= extenalId;
        customField.defaultValue	= '"904242"';
        customField.caseSensitive	= caseSensitive;
        
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customField } );
        handleSaveResults(results[0]);
        
    }
    public static void createNumberField(String objectApiName, String fieldLabel, Boolean required, 
                                    Boolean extenalId, Boolean unique){
        
        MetadataService.MetadataPort service 	= createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName 		= objectApiName+'.'+fieldLabel.replace(' ', '_')+'__c'; // Account - Active => Account.Active__c
        customField.label 			= fieldLabel;
        customField.type_x 			= 'Number';
        customField.description 	= 'This is the field created from Custom Metadata';
        customField.inlineHelpText	= 'This is the field created from Custom Metadata';
        customField.scale			= 2;
        customField.precision		= 8;
        customField.required		= required;
        customField.unique			= unique;
        customField.externalId		= extenalId;
        
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customField } );
        handleSaveResults(results[0]);
        
    }
    
    public static void createLookupField(String objectApiName, String fieldLabel, String relatedToAPiName, 
                                         String typex, String description, String helpText, String relationshipLabel, 
                                         String relationshipName){
        
        MetadataService.MetadataPort service 	= createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName 		  			= objectApiName+'.'+fieldLabel.replace(' ', '_')+'__c';
        customField.label 			  			= fieldLabel;
        customField.type_x 			  			= typex; // Lookup // MasterDetail
        customField.description 	  			= 'This is the '+typex+' field related to '+relatedToApiName +' Object';
        customField.inlineHelpText	  			= 'This is the '+typex+' field related to '+relatedToApiName +' Object';
        customField.relationshipLabel 			= relationshipLabel;
        customField.relationshipName  			= relationshipName;
        customField.referenceTo 	  			= relatedToApiName;
        
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customField } );
        handleSaveResults(results[0]);
    }
    
    public static void createPicklistField(String objectApiName, String fieldLabel, List<String> options){
        
        MetadataService.MetadataPort service 	= createService();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName 		= objectApiName+'.'+fieldLabel.replace(' ', '_')+'__c';
        customField.label 			= fieldLabel;
        customField.type_x 			= 'Picklist';
        customField.description 	= 'This is the picklist field created from Custom Metadata while recording UDEMY INTEGRATION';
        customField.inlineHelpText	= 'This is the picklist field created from Custom Metadata while recording UDEMY INTEGRATION';
        
        MetadataService.ValueSet valueSetDef 		 = new MetadataService.ValueSet();
        
        MetadataService.ValueSetValuesDefinition valueDefinition = new MetadataService.ValueSetValuesDefinition();
        
        List<MetadataService.CustomValue> values 	 = new List<MetadataService.CustomValue>();        
        for(String value : options){
            MetadataService.CustomValue customValue = new MetadataService.CustomValue();
            customValue.fullName  = value; 
            customValue.default_x = false;
            customValue.isActive  = true;
            customValue.label     = value;
            values.add(customValue);
        }
        valueDefinition.value  			= values;
        valueDefinition.sorted 			= true;
        
        valueSetDef.valueSetDefinition  = valueDefinition;
        valueSetDef.restricted			= true;
        
        customField.valueSet 		    = valueSetDef;
        customField.required			= true;
        List<MetadataService.SaveResult> results = service.createMetadata( new MetadataService.Metadata[] { customField } );
        handleSaveResults(results[0]);
    }
    
    public static void updateFieldLevelSecurityToProfile(List<String> filedApiNames, String objectApiName, String profile){
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile admin = new MetadataService.Profile();
        admin.fullName = profile;
        admin.custom   = false;
        
        List<MetadataService.ProfileFieldLevelSecurity> fieldPermssions = new List<MetadataService.ProfileFieldLevelSecurity>();
        for(String field : filedApiNames){
            MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
            fieldSec.field = objectApiName+'.'+field; //Udemy_IntegrationAN__c.SSN__c
            fieldSec.editable = true;
            fieldPermssions.add(fieldSec);
        }
        
        admin.fieldPermissions  = fieldPermssions ;
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { admin });
        handleSaveResults(results[0]);
    }
    public static void updateFieldLevelSecurityToPermissionSet(List<String> filedApiNames, String objectApiName, String permSet
                                                              ,String label){
        MetadataService.MetadataPort service = createService();
        
        MetadataService.PermissionSet permissionSet = new MetadataService.PermissionSet ();
        permissionSet.fullName = permSet;
        permissionSet.label    = label;
                                                                  
        List<MetadataService.PermissionSetFieldPermissions> fieldPermissions = new List<MetadataService.PermissionSetFieldPermissions>();
        for(String field : filedApiNames){
            MetadataService.PermissionSetFieldPermissions fieldSec = new MetadataService.PermissionSetFieldPermissions();
            fieldSec.field = objectApiName+'.'+field; 
            fieldSec.editable = true;
            fieldPermissions.add(fieldSec);
        }
        
        permissionSet.fieldPermissions = fieldPermissions;
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { permissionSet });
        handleSaveResults(results[0]);
    }
    
    public static MetadataService.ValidationRule readValidationRule(String apiName){
        
        MetadataService.MetadataPort service = createService();
        MetadataService.ValidationRule validationRuleDetails = (MetadataService.ValidationRule) service.readMetadata('ValidationRule',
                                                                new String[] { apiName }).getRecords()[0];
        return validationRuleDetails;
    }
    
    public static void deactivateValidationMetadata(String fullName, Boolean active){
        
        MetadataService.ValidationRule existingRule = readValidationRule(fullName);
        
        MetadataService.MetadataPort service   = createService();
        
        MetadataService.ValidationRule	rule   = new MetadataService.ValidationRule();
        rule.fullName                          = fullName;
        rule.active                            = active;
        rule.errorConditionFormula             = existingRule.errorConditionFormula;
        rule.description                       = existingRule.description;
        rule.errorMessage                      = existingRule.errorMessage;
        if(existingRule.errorDisplayField != null )
        	rule.errorDisplayField			   = existingRule.errorDisplayField;
        
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { rule });
        handleSaveResults(results[0]);
    }
    
    public static void deleteMetadata(String type_x, String fullName){
        MetadataService.MetadataPort service = createService();
        List<MetadataService.DeleteResult> results = service.deleteMetadata( type_x, new String[] { 
            fullName
       	});
        handleDeleteResults(results[0]);
    }
    
    public static void createPage(String label, String fullName){
        
        MetadataService.MetadataPort service = createService();
        MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
        apexPage.apiVersion = 50;
        apexPage.fullName   = fullName;
        apexPage.label 		= label;
        apexPage.description = 'Created from MD API';
        apexPage.availableInTouch	= true;
        apexPage.confirmationTokenRequired = true;
        
        String content = '<apex:page>'+
            			'<apex:slds/>'+
                          '<!-- Begin Default Content REMOVE THIS -->'+
                          '<h1>Congratulations</h1>'+
                          'This is your new Page for MD API'+
                          '<!-- End Default Content REMOVE THIS -->'+
                        '</apex:page>';
        
        apexPage.content 	= EncodingUtil.base64Encode(Blob.valueOf(content));
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { apexPage });
        handleSaveResults(results[0]);
    }
    
    public static void createLightningComponent(String fullName){
        MetadataService.MetadataPort service = createService();
        MetadataService.AuraDefinitionBundle auraBundle = new MetadataService.AuraDefinitionBundle();
        auraBundle.fullName = fullName;
        auraBundle.type_x = 'Component';
        auraBundle.description = 'Created form MD API';
        auraBundle.apiVersion = 50;
        auraBundle.markup = EncodingUtil.base64Encode(Blob.valueOf(
            '<aura:component>' +
                '<aura:attribute name="val1" type="String" default="Value"/>' +
                '<aura:attribute name="val2" type="String" />' +
                '<aura:handler name="init" value="{!this}" action="{!c.myAction}"/>' +
                '<ui:outputText value="Hello world!"/>' +
                '<ui:outputText value="{!v.val1}"/>' +
                '<ui:outputText value="{!v.val2}"/>' +
            '</aura:component>'));
        auraBundle.controllerContent = EncodingUtil.base64Encode(Blob.valueOf(
            '({' +
                'myAction : function(component) {' +
                    'component.set(\'v.val1\',\'Value1\');' +
                    'component.set(\'v.val2\',\'Value2\');' +
                '}' +
            '})'));
        auraBundle.helperContent = EncodingUtil.base64Encode(Blob.valueOf('({})'));
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { auraBundle });
        handleSaveResults(results[0]);
    }
    
    public static void deleteMetadataRecord(String metadataType, List<String> names){
        MetadataService.MetadataPort service = createService();
        List<String> recordsToDelete = new List<String>();
        for(String name : names){
            recordsToDelete.add(metadataType+'.'+name);
        }
        service.deleteMetadata('CustomMetadata', recordsToDelete); //250
    }
    
    public static void addFieldsToPageLayout(List<String> fields, String pageLayout, String sectionName){
        
        //'Udemy_IntegrationAN__c-Udemy IntegrationAN Layout'
        //// Udemy_IntegrationAN__c-Udemy IntegrationAN Layout
        MetadataService.MetadataPort service = createService();
        
        MetadataService.Layout layout =(MetadataService.Layout) service.readMetadata('Layout',new String[] { pageLayout }).getRecords()[0];
        
        if(layout.layoutSections == null ){
            layout.layoutSections = new MetadataService.LayoutSection[]{};
        }
        
        MetadataService.LayoutSection layoutSection  = new MetadataService.LayoutSection();
        
        MetadataService.LayoutColumn[] layoutColumns = new MetadataService.LayoutColumn[]{};
        
        MetadataService.LayoutItem[]   layoutItems 	 = new MetadataService.LayoutItem[]{};

        MetadataService.LayoutColumn column	= new MetadataService.LayoutColumn();
        
        for(String field : fields){
            MetadataService.LayoutItem item	= new MetadataService.LayoutItem();
            item.field 	  = field;
            item.behavior = 'Required';
            layoutItems.add(item);
        }
        column.layoutItems	= layoutItems;
        layoutColumns.add(column);
        
        layoutSection.label			= sectionName;
        layoutSection.customLabel	= true;
        layoutSection.detailHeading	= true;
        layoutSection.editHeading	= true;
        layoutSection.layoutColumns = layoutColumns;
        
        layoutSection.style			= 'TwoColumnsLeftToRight';
        layout.layoutSections.add(layoutSection);
            
        List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] { layout });
        handleSaveResults(results[0]);

    }
    
    public class MetadataServiceExamplesException extends Exception { }
    public static void handleSaveResults(MetadataService.SaveResult saveResult){
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        System.debug(' saveResult.errors \n '+saveResult.errors);
        if(saveResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors) {
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            }
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
            
            System.debug(' Message  '+String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
    
    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult){
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
    
    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult){
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + upsertResult.fullName + '.');
            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
    
}
