import { LightningElement, track, wire } from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityController.getOpportunities';
import updateOpportunityStatus from '@salesforce/apex/OpportunityController.updateOpportunityStatus';
import getOpportunityStageNames from '@salesforce/apex/OpportunityController.getOpportunityStageNames';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class updateMultipleOpportunities extends LightningElement {
    @track opportunities = [];
    @track statusOptions = []; 
    @track selectedOppIds = [];
    @track selectedStatus;
    @track isLoading = false; 
    
    wiredOpportunitiesResult; 
    currentPage = 1;
    pageSize = 20; 
    totalPages = 1;

    get listedOpportunities() {
        const start = (this.currentPage - 1) * this.pageSize;
        return this.opportunities.slice(start, start + this.pageSize);
    }


    @wire(getOpportunities)
    wiredOpportunities(response) { 
        this.wiredOpportunitiesResult = response; 
        if (response.data) {
            this.opportunities = response.data;
            this.totalPages = Math.ceil(response.data.length / this.pageSize);
            this.error = null;
        } else if (response.error) {
            this.error = response.error;
            this.opportunities = [];
        }
    }

    @wire(getOpportunityStageNames)
    wiredStageNames(response) {
        if (response.data) {
            this.statusOptions = response.data.map(status => ({ label: status, value: status }));
            this.error = null;
        } else if (response.error) {
            this.error = response.error;
            this.statusOptions = [];
        }
    }

    handleSelection(event) {
        const oppId = event.target.value;
        if (event.target.checked) {
            this.selectedOppIds.push(oppId);
        } else {
            const index = this.selectedOppIds.indexOf(oppId);
            if (index !== -1) {
                this.selectedOppIds.splice(index, 1);
            }
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.target.value;
    }

    updateOpportunities() {
        // exit if there are no selected opps or status
        if (!this.selectedOppIds.length || !this.selectedStatus) return;
    
        this.isLoading = true;
    
        updateOpportunityStatus({
            oppIds: this.selectedOppIds,
            status: this.selectedStatus
        })
        .then(() => {
            this.selectedOppIds = [];
            this.selectedStatus = undefined;
    
            return refreshApex(this.wiredOpportunitiesResult).then(() => {
                this.showToast('Success', 'Opportunities Updated Successfully', 'success');
            });
        })
        .catch(error => {
            this.handleError(error);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }
    
    
    handleError(error) {
        let errorMessage = 'Unknown error';
        if (Array.isArray(error.body)) {
            errorMessage = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            errorMessage = error.body.message;
        }
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            })
        );
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }

    nextPage() {
        if (this.currentPage < this.totalPages) this.currentPage++;
    }

    previousPage() {
        if (this.currentPage > 1) this.currentPage--;
    }

    navigateToOpportunity(event) {
        const oppId = event.currentTarget.getAttribute('data-id');
        window.open(`/lightning/r/Opportunity/${oppId}/view`, '_blank');
    }
}
