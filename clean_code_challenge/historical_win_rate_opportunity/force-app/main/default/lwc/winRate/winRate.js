import { LightningElement, api, track } from 'lwc';

export default class WinRate extends LightningElement {
    @api label;
    @api commercialhitrate;
    @api tenderhitrate;
    @api successrate;
    @api message;
    @api href;
    @api lastClosedOpportunity;
    @track lastClosedOpportunityHref;
    @api lastClosedOpportunityMessage;

    connectedCallback() {
        if (this.lastClosedOpportunity) {
            this.lastClosedOpportunityHref =
                '/lightning/r/Opportunity/' +
                this.lastClosedOpportunity.Id +
                '/view';
        }
        console.log(this.lastClosedOpportunityHref);
    }
}
