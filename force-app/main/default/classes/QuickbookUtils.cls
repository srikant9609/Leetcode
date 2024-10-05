public with sharing class QuickbookUtils {
    public PageReference authorize() {
        
        qb_Metadata__mdt config = qb_Metadata__mdt.getInstance('QB_Data');

        if(config !=null){
            String redirectUrl=System.URL.getOrgDomainUrl().toExternalform()+'/apex/'+config.PageName__c;
            System.debug('redirectUrl'+redirectUrl);
           // https://appcenter.intuit.com/connect/oauth2?
           // client_id=Q3ylJatCvnkYqVKLmkxxxxxxxxxxxxxxxkYB36b5mws7HkKUEv9aI&response_type=code&
            // scope=com.intuit.quickbooks.accounting&
            // redirect_uri=https://www.mydemoapp.com/oauth-redirect&
             // state=security_token%3D138r5719ru3e1%26url%3Dhttps://www.mydemoapp.com/oauth-redirect
         String authUrl=config.auth_url__c + '?client_id='+config.Client_Id__c +'&response_type=code&scope=openid email profile com.intuit.quickbooks.accounting com.intuit.quickbooks.payment&redirect_uri='+redirectUrl+'&state='+UserInfo.getOrganizationId()+redirectUrl;
         System.debug('authUrl');
         return new PageReference(authUrl);

        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not found'));
            return null; 
        }
  }

   public void getAccessToken(){
    qb_Metadata__mdt config = qb_Metadata__mdt.getInstance('QB_Data');
     if(config !=null){
        String code= ApexPages.currentPage().getParameters().get('code');
         String realmId= ApexPages.currentPage().getParameters().get('realmId');
         String redirect_uri = System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.PageName__c;
         HttpRequest httReq = new HttpRequest();
         httReq.setMethod('POST');
         httReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
         httReq.setHeader('Accept', 'application/json');
         httReq.setEndpoint(config.token_url__c);
         String tokenBody = 'grant_type=authorization_code&code='+code+'&redirect_uri='+redirect_uri
         +'&client_id='+config.Client_Id__c+'&client_secret='+config.Client_Secret__c;
           httReq.setBody(tokenBody);
           try {
            HttpResponse httpRes = (new Http()).send(httReq);
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
                String fullName = 'qb_Metadata.QB_Data';
                String label    = 'QB_Data';
                Map<String, Object> fieldWithValuesMap = prepareMetadata(httpRes.getBody(),'');
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfull!'));
            }
           }
           catch (CalloutException ex) {
            
                System.debug(ex);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }catch (Exception ex) {
                System.debug(ex);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage() ));
            }
     }else{
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not found'));
     }
   }
   public static Map<String, Object> prepareMetadata(String requestBody, String realmId){
    Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
    String access_token  = (String)responseMap.get('access_token');
    String refresh_token = (String)responseMap.get('refresh_token');
    Integer expires_in   = (Integer)responseMap.get('expires_in');
    
    Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
    fieldWithValuesMap.put('access_token__c', access_token);
    fieldWithValuesMap.put('expires_in__c',expires_in);
    fieldWithValuesMap.put('expires_in_time__c', System.now().addSeconds(expires_in) );
    fieldWithValuesMap.put('refresh_token__c', refresh_token);
    if(!String.isBlank(realmId)){
        fieldWithValuesMap.put('realmId__c', realmId);
    }
    return fieldWithValuesMap;
}

public static Boolean isValid(qb_Metadata__mdt config){
    Boolean isValid = true;
    if(config.expires_in_time__c <= System.now()){
        isValid = false;
    }
    return isValid;
}
public static Map<String, Object> refreshToken(qb_Metadata__mdt config){
        
    String tokenUrl = config.token_url__c;
    
    String requestBody = 'grant_type=refresh_token&client_id='+config.client_id__c
                        +'&client_secret='+config.client_secret__c+'&refresh_token='+config.refresh_token__c;
    
    System.debug(requestBody);
    HttpRequest httpReq = PS_CalloutUtils.prepareRequest(tokenUrl,'POST',requestBody,'application/json', 'application/x-www-form-urlencoded');
    Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
    try{
        HttpResponse httpRes = (new Http()).send(httpReq);
        if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201 ){
            fieldWithValuesMap = prepareMetadata(httpRes.getBody(),'');
        }else{
            
        }
    }catch(System.CalloutException ex){
        
    }catch(System.Exception ex){
        
    }
    return fieldWithValuesMap;
}


   //https://accenture-6e9-dev-ed--c.develop.vf.force.com/apex/newQuickbookPage?code=AB11727074769LBeknFnCIBEWnbMMsVXRd76DGc2ytIsMeztGB&state=00DIR000001ZNCb2AOhttps%3A%2F%2Faccenture-6e9-dev-ed.develop.my.salesforce.com%2Fapex%2FnewQuickbookPage&realmId=4620816365228453470
}