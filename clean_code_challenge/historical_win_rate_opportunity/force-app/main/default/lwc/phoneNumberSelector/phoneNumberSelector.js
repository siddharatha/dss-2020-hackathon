import { LightningElement, track } from 'lwc';
import { phoneNumbersByCountry } from './phonenumbers';
export default class LocalVoicePhoneNumberSelector extends LightningElement {
    @track countries = Object.keys(phoneNumbersByCountry).map(eachCountry => {
        return {
            label: eachCountry,
            value: eachCountry
        };
    });

    @track selectedCountry;
    @track selectedPhoneNumber;
    @track categories;
    @track selectedCategory;
    @track phoneNumbersList;
    @track hasCategories = false;
    @track hasPhoneNumbers = false;

    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
        this.reset();
        const phoneNumbers = phoneNumbersByCountry[this.selectedCountry];
        if (typeof phoneNumbers === 'string') {
            this.selectedPhoneNumber = phoneNumbers;
            this.recievedPhoneNumber(this.selectedPhoneNumber);
        } else if (Array.isArray(phoneNumbers)) {
            this.hasPhoneNumbers = true;
            this.phoneNumbersList = phoneNumbers.map(eachNumber => {
                return {
                    label: eachNumber,
                    value: eachNumber
                };
            });
        } else {
            this.hasCategories = true;
            this.categories = Object.keys(phoneNumbers).map(eachCategory => {
                return {
                    label: eachCategory,
                    value: eachCategory
                };
            });
        }
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        const phoneNumbers =
            phoneNumbersByCountry[this.selectedCountry][this.selectedCategory];
        if (typeof phoneNumbers === 'string') {
            this.selectedPhoneNumber = phoneNumbers;
            this.recievedPhoneNumber(this.selectedPhoneNumber);
        } else if (Array.isArray(phoneNumbers)) {
            this.hasPhoneNumbers = true;
            this.phoneNumbersList = phoneNumbers.map(eachNumber => {
                return {
                    label: eachNumber,
                    value: eachNumber
                };
            });
        }
    }

    handlePhoneNumberChange(event) {
        this.selectedPhoneNumber = event.detail.value;
        this.recievedPhoneNumber(this.selectedPhoneNumber);
    }

    recievedPhoneNumber(phonenumber) {
        this.dispatchEvent(
            new CustomEvent('phonenumberselect', {
                detail: {
                    phonenumber
                }
            })
        );
    }

    reset() {
        this.categories = null;
        this.phoneNumbersList = null;
        this.selectedCategory = null;
        this.hasCategories = false;
        this.hasPhoneNumbers = false;
        this.selectedPhoneNumber = null;
    }
}
