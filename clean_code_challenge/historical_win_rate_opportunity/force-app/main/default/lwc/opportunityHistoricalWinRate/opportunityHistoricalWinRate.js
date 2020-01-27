import { LightningElement, track, api, wire } from 'lwc';
import getEndUserInvestorOpps from '@salesforce/apex/OpportunityDiscoveryServices.getEndUserInvestorOpps';
import getRelatedAccountOpps from '@salesforce/apex/OpportunityDiscoveryServices.getRelatedAccountOpps';
import getMarketSegmentOpps from '@salesforce/apex/OpportunityDiscoveryServices.getMarketSegmentOpps';
import getValueChainPlayersWinRateByOpportunityId from '@salesforce/apex/OpportunityDiscoveryServices.getValueChainPlayersWinRateByOpportunityId';
export default class OpportunityHistoricalWinRate extends LightningElement {
    @api recordId;
    @track loading = false;
    @track hwr_account;
    /* = {
        commercialhitrate: 0.5688794609433492,
        counter: 4,
        href: '/001A0000014MNUUIA4',
        label: 'Account Cadillac Fairview',
        lastClosedOpportunity: {
            Id: '0061200000XIbzWAAT',
            StageName: '0 - Closed',
            Amount: 24575.0,
            CloseDate: new Date('2018-02-28 00:00:00'),
            Status__c: 'Cancelled by Customer',
            Name:
                'DE-ITD-0040010036-GO301151 - 2017 - Ingram Micro Distribution GmbH - B',
            CurrencyISOCode: 'USD'
        },
        lastClosedOpportunityMessage: null,
        message: null,
        successrate: 1.0,
        tenderhitrate: 1.0
    };*/
    @track hwr_ms;
    @track hwr_euai;
    @track historicalWinRateValueChainPlayers;

    @wire(getEndUserInvestorOpps, { opportunityId: '$recordId' })
    wiredFunc({ data }) {
        if (data) {
            this.hwr_euai = data;
        }
    }
    @wire(getRelatedAccountOpps, { opportunityId: '$recordId' })
    wiredFuncRelatedAccountOpps({ data }) {
        if (data) {
            this.hwr_account = data;
        }
    }
    @wire(getMarketSegmentOpps, { opportunityId: '$recordId' })
    wiredFuncMarketSegmentOpps({ data }) {
        if (data) {
            this.hwr_ms = data;
        }
    }

    @wire(getValueChainPlayersWinRateByOpportunityId, {
        opportunityId: '$recordId'
    })
    wiredFuncValueChainPlayersWinRateByOpportunityId({ data }) {
        if (data) {
            this.historicalWinRateValueChainPlayers = data;
        }
    }
}
