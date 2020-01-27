public class OpportunityUtility {

   @AuraEnabled(cacheable=true)
   public static WinRateWrapper getEndUserInvestorOpps(String opportunityId){              
       List<Opportunity> oppRecordsForEUC = [select id,EndUserCustomer__c,CountryOfDestination__c,EndUserCustomer__r.Name from Opportunity where id=:opportunityId];
       if(oppRecordsForEUC.size()>0 && oppRecordsForEUC[0].EndUserCustomer__c !=null){
       List<Opportunity> lstOpportunties = [select id,StageName,Amount,Name,CurrencyISOCode,EndUserCustomer__c,CloseDate,Status__c,IsClosed from Opportunity where Status__c!=null and Amount!=null and EndUserCustomer__c=:oppRecordsForEUC[0].EndUserCustomer__c and CloseDate = LAST_N_MONTHS:36 order by CloseDate DESC limit 50000];
       if(lstOpportunties.size()>0)
       return calculateHitRates(lstOpportunties,'End User Account - Investor: '+ oppRecordsForEUC[0].EndUserCustomer__r.Name,'/'+oppRecordsForEUC[0].EndUserCustomer__c);     
       else
       return new WinRateWrapper(null,null,null,0,'No Opportunites with same End User Account - Investor closed in the last 36 months','End User Account - Investor: '+ oppRecordsForEUC[0].EndUserCustomer__r.Name,'/'+oppRecordsForEUC[0].EndUserCustomer__c,null,null);
       }
       else{
        return new WinRateWrapper(null,null,null,0,'No End User Account - Investor on this Opportunity','End User Account - Investor',null,null,null);
       }
   } 

   @AuraEnabled(cacheable=true)
   public static WinRateWrapper getRelatedAccountOpps(String opportunityId){        
       List<Opportunity> oppRecordsForEUC = [select id,AccountId,CountryOfDestination__c,Account.Name from Opportunity where id=:opportunityId];
       if(oppRecordsForEUC.size()>0 && oppRecordsForEUC[0].AccountId!=null){
       List<Opportunity> lstOpportunties = [select id,StageName,Amount,Name,CurrencyISOCode,EndUserCustomer__c,CloseDate,Status__c,IsClosed from Opportunity where Status__c!=null and Amount!=null and AccountId=:oppRecordsForEUC[0].AccountId and CloseDate = LAST_N_MONTHS:36 order by CloseDate DESC limit 50000];
       if(lstOpportunties.size()>0)
        return calculateHitRates(lstOpportunties,'Account: '+ oppRecordsForEUC[0].Account.Name,'/'+oppRecordsForEUC[0].AccountId);
       else
        return new WinRateWrapper(null,null,null,0,'No Opportunities with same Account in the last 36 months','Account '+ oppRecordsForEUC[0].Account.Name,'/'+oppRecordsForEUC[0].AccountId,null,'No Closed Opportunities within the past 36 months');
       }
       else {return new WinRateWrapper(null,null,null,0,'No Related Account on this Opportunity','Account','#',null,'No Closed Opportunities within the past 36 months');}
   }

   @AuraEnabled(cacheable=true)
   public static WinRateWrapper getMarketSegmentOpps(String opportunityId){
        List<Opportunity> oppRecordsForEUC = [select id,toLabel(MarketSegment__c),CountryOfDestination__c from Opportunity where id=:opportunityId];       
       if(oppRecordsForEUC.size()>0 && oppRecordsForEUC[0].MarketSegment__c!=null && oppRecordsForEUC[0].CountryOfDestination__c!=null){
        List<Opportunity> lstOpportunties = [select id,StageName,Amount,Name,CurrencyISOCode,EndUserCustomer__c,CloseDate,Status__c,IsClosed from Opportunity where Status__c!=null and Amount!=null and MarketSegment__c=:oppRecordsForEUC[0].MarketSegment__c and CloseDate = LAST_N_MONTHS:36 and CountryOfDestination__c=:oppRecordsForEUC[0].CountryOfDestination__c order by CloseDate DESC limit 50000];
        if(lstOpportunties.size()>0){
        WinRateWrapper winratewrapperrecord =  calculateHitRates(lstOpportunties,'Market Segment: '+oppRecordsForEUC[0].MarketSegment__c,'#');
        winratewrapperrecord.lastClosedOpportunity=null;
        return winratewrapperrecord;
        }
        else
        return new WinRateWrapper(null,null,null,0,'No Opportunites with same Market Segment in the last 36 months','Market Segment: '+oppRecordsForEUC[0].MarketSegment__c,'#',null,null);
       }
       else {
           return new WinRateWrapper(null,null,null,0,'No MarketSegment on this Opportunity','Market Segment','#',null,null);
       }
   }

   @AuraEnabled(cacheable=true)
   public static List<OpportunityUtility.WinRateWrapper> getValueChainPlayersWinRateByOpportunityId(String opportunityId){
        Map<Id,Account> valueChainPlayersAccounts = new Map<Id,Account>();
        Opportunity opportunityRecord = [select CountryOfDestination__c ,(select id,Account__c,Contact__c,Account__r.Name,Contact__r.Name from Value_Chain_Players__r) from Opportunity where Id=:opportunityId];
        List<OpportunityUtility.WinRateWrapper> lstWinRateWrapper = new List<OpportunityUtility.WinRateWrapper>();                
        if(opportunityRecord.Value_Chain_Players__r.size()>0)
        {
                for(OPP_ValueChainPlayers__c valueChainPlayerRecord: opportunityRecord.Value_Chain_Players__r)
                {
                if(valueChainPlayerRecord.Account__c!=null){
                        valueChainPlayersAccounts.put(valueChainPlayerRecord.Account__c,new Account(Id=valueChainPlayerRecord.Account__c,Name=valueChainPlayerRecord.Account__r.Name));
                    }            
                }   
                Map<Id,Id> accountIdByOpportunityId = new Map<Id,Id>();                 
                Set<Id> opportunityIdsToQuery = new Set<Id>();
                for(OPP_ValueChainPlayers__c valueChainPlayerRecord : [select OpportunityName__c,Account__c from OPP_ValueChainPlayers__c where OpportunityName__r.Status__c!=null and OpportunityName__r.Amount!=null and OpportunityName__r.CloseDate = LAST_N_MONTHS:36 and OpportunityName__r.CountryOfDestination__c=:opportunityRecord.CountryOfDestination__c and Account__c in :valueChainPlayersAccounts.keySet() limit 10000]){                                        
                    accountIdByOpportunityId.put(valueChainPlayerRecord.OpportunityName__c,valueChainPlayerRecord.Account__c);
                }                
                opportunityIdsToQuery.addAll(accountIdByOpportunityId.keySet());
                // opportunites where value chain players are accounts on opportunity
                Map<Id,Opportunity> opportunitesWithMatchingAccountById = new Map<Id,Opportunity>([select id,StageName,Amount,Name,CurrencyISOCode,EndUserCustomer__c,CloseDate,Status__c,AccountId,IsClosed from Opportunity where Status__c!=null and Amount!=null and CloseDate = LAST_N_MONTHS:36 and CountryOfDestination__c=:opportunityRecord.CountryOfDestination__c and AccountId in :valueChainPlayersAccounts.keySet() limit 10000]);
                Map<Id,Set<Opportunity>> opportunitesByAccountId = new Map<Id,Set<Opportunity>>();
                for(Opportunity opportunityRecord1: opportunitesWithMatchingAccountById.values())
                {
                    if(opportunitesByAccountId.containsKey(opportunityRecord1.AccountId))
                    {
                        opportunitesByAccountId.get(opportunityRecord1.AccountId).add(opportunityRecord1);
                    }
                    else
                    {
                        opportunitesByAccountId.put(opportunityRecord1.AccountId,new Set<Opportunity>{opportunityRecord1});
                    }
                }

                if(!opportunityIdsToQuery.containsAll(opportunitesWithMatchingAccountById.keySet())){                    
                opportunityIdsToQuery.removeAll(opportunitesWithMatchingAccountById.keySet());                
                for(Opportunity opportunityRecord2: [select id,StageName,Amount,Name,CurrencyISOCode,EndUserCustomer__c,CloseDate,Status__c,AccountId,IsClosed from Opportunity where Id in :opportunityIdsToQuery limit 10000])
                    {
                        Id accountId = accountIdByOpportunityId.get(opportunityRecord2.Id);
                        if(opportunitesByAccountId.containsKey(accountId)){
                            opportunitesByAccountId.get(accountId).add(opportunityRecord2);
                        }
                        else{
                            opportunitesByAccountId.put(accountId,new Set<Opportunity>{opportunityRecord2});
                        }
                    }
                }

                // group opportunites by Account
                Map<Id,Account> accountsById = new Map<Id,Account>([select Id,Name from Account where id in :opportunitesByAccountId.keySet()]);                
                for(Id accountId: opportunitesByAccountId.keySet()){
                    if(opportunitesByAccountId.get(accountId).size()>0){
                        List<Opportunity> lstOpportunity = new List<Opportunity>();
                        lstOpportunity.addAll(opportunitesByAccountId.get(accountId));
                        // TODO - implement the sort logic for the opportunity close date picker
                        lstWinRateWrapper.add(calculateHitRates(lstOpportunity, accountsById.get(accountId).Name, '/'+accountId));
                    }
                    else{
                        lstWinRateWrapper.add(new WinRateWrapper(null,null,null,0,'No Closed Opportunities within the past 36 months',accountsById.get(accountId).Name,'/'+accountId,null,null));
                    }
                }                
        }       
       else {
          lstWinRateWrapper.add(new WinRateWrapper(null,null,null,0,'No Value Chain Players on this Opportunity','Value Chain Players','#',null,null));          
       }
       return lstWinRateWrapper;
   }

   public class WinRateWrapper{   
        @AuraEnabled public Double tenderhitrate{get;set;}
        @AuraEnabled public Double commercialhitrate{get;set;}
        @AuraEnabled public Double successrate{get;set;}
        @AuraEnabled public Integer counter{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String href{get;set;}
        @AuraEnabled public Opportunity lastClosedOpportunity {get;set;}
        @AuraEnabled public String lastClosedOpportunityMessage {get;set;}
       
        public WinRateWrapper(Double tenderhitrate,Double commercialhitrate,Double successrate,Integer counter,String message,String label,String href, Opportunity lastClosedOpportunity,String lastClosedOpportunityMessage)
        {
            this.tenderhitrate=tenderhitrate;
            this.commercialhitrate=commercialhitrate;
            this.successrate=successrate;            
            this.counter = counter;
            this.message = message;            
            this.label = label;            
            this.href = href;
            this.lastClosedOpportunity = lastClosedOpportunity; 
            this.lastClosedOpportunityMessage = lastClosedOpportunityMessage;           
        }
   }
   

    public static WinRateWrapper calculateHitRates(List<Opportunity> lstOpportunites,String label, String href){
        try{
            Double totalwinamount=0;
            Double totallostamountwithstage5and6=0;
            Double totalcancelledamountwithstage5and6=0;
            Double totallostamount=0;
            Double totalcancelledamount=0;

            Double tenderhitrate = 0;
            Double commercialhitrate=0;
            Double successrate=0;
            Integer counter = 0;

            Opportunity lastClosedOpportunity;
            
            for(Opportunity oppRecord: lstOpportunites){
                    if(oppRecord.isClosed && lastClosedOpportunity==null){
                        lastClosedOpportunity=oppRecord;
                    }
                    if (isOpportunityWon(oppRecord)) {
                        totalwinamount +=
                            oppRecord.Amount;
                    }
                    if (isOpportunityLost(oppRecord)) {
                        totallostamount +=
                            oppRecord.Amount;
                    }
                    if (isOpportunityCancelled(oppRecord)) {
                        totalcancelledamount +=
                            oppRecord.Amount;
                    }
                    if (isOpportunityCancelledWithStage5And6(oppRecord)) {
                        totalcancelledamountwithstage5and6 +=
                            oppRecord.Amount;
                    }

                    if (isOpportunityLostWithStage5And6(oppRecord)) {
                        totallostamountwithstage5and6 +=
                            oppRecord.Amount;
                    }
        }

        Double tenderhitrate_denominator = totalwinamount + totallostamountwithstage5and6 + totalcancelledamountwithstage5and6;
        Double commercialhitrate_denominator = totalwinamount + totallostamount + totalcancelledamount;
        Double successrate_denominator = totalwinamount + totallostamount ;
        if(tenderhitrate_denominator!=0){
        tenderhitrate = totalwinamount / tenderhitrate_denominator;
        }
        if(commercialhitrate_denominator!=0){
        commercialhitrate = totalwinamount / commercialhitrate_denominator;
        }
        if(successrate_denominator!=0){
        successrate = totalwinamount / successrate_denominator;
        }

        return new WinRateWrapper(tenderhitrate,commercialhitrate,successrate,lstOpportunites.size(),null,label,href,lastClosedOpportunity,null); 
        }
        catch(Exception ex){
            return new WinRateWrapper(null,null,null,lstOpportunites.size(),ex.getMessage(),label,href,null,'No Closed Opportunities within the past 36 months'); 
        }
    }


    public static Boolean isOpportunityWon(Opportunity opportunityRecord) {
        return opportunityRecord.Status__c.startsWithIgnoreCase('won');    
    }

    public static Boolean isOpportunityLost(Opportunity opportunityRecord) {
        return 
            opportunityRecord.Status__c.startsWithIgnoreCase('lost');    
    }

    public static Boolean isOpportunityCancelled(Opportunity opportunityRecord) {
        return 
            opportunityRecord.Status__c.startsWithIgnoreCase('cancelled');    
    }

    public static Boolean isOpportunityCancelledWithStage5And6(Opportunity opportunityRecord) {
        return (        
            opportunityRecord.Status__c.startsWithIgnoreCase('cancelled') &&
            (opportunityRecord.StageName.startsWithIgnoreCase('5') ||
                opportunityRecord.StageName.startsWithIgnoreCase('6'))
        );
    }

    public static Boolean isOpportunityLostWithStage5And6(Opportunity opportunityRecord) {
        return (        
            opportunityRecord.Status__c.startsWithIgnoreCase('lost') &&
            (opportunityRecord.StageName.startsWithIgnoreCase('5') ||
                opportunityRecord.StageName.startsWithIgnoreCase('6'))
        );
    }

}