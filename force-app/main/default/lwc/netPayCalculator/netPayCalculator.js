import { LightningElement } from 'lwc';
const federalIncomeTax = 0.1691388;
const socialSecurity = 0.062;
const medicareWithholding = 0.0145;
const lowPay = 6914.97;
const mediumPay = 8172.24;
const highPay = 9429.51;

export default class NetPayCalculator extends LightningElement {

    baseTakeHomePay = 100000;

    annualAfterall = 75436;
    monthlyPay = 6286.34;

    showNotWorthIt = false;
    showLowPay = false;
    showMediumPay = false;
    showHighPay = false;

    calculatePay(){
        let annualAfterFed = this.baseTakeHomePay * federalIncomeTax;
        let annualAfterSS = this.baseTakeHomePay * socialSecurity;
        let annualAfterMedicare = this.baseTakeHomePay * medicareWithholding;
        this.annualAfterAll = this.baseTakeHomePay - (annualAfterFed + annualAfterSS + annualAfterMedicare);
        this.monthlyPay = Math.round(((this.annualAfterAll / 12) + Number.EPSILON) * 100) / 100;

        this.showCalculatedPay();

    }

    showCalculatedPay(){
        if(this.monthlyPay < lowPay){
            this.showNotWorthIt = true;
            this.showLowPay = false;
            this.showMediumPay = false;
            this.showHighPay = false;
        } else if(this.monthlyPay >= lowPay && this.monthlyPay < mediumPay){
            this.showNotWorthIt = false;
            this.showLowPay = true;
            this.showMediumPay = false;
            this.showHighPay = false;
        } else if(this.monthlyPay >= mediumPay && this.monthlyPay < highPay){
            this.showNotWorthIt = false;
            this.showLowPay = false;
            this.showMediumPay = true;
            this.showHighPay = false;
        } else if(this.monthlyPay >= highPay){
            this.showNotWorthIt = false;
            this.showLowPay = false;
            this.showMediumPay = false;
            this.showHighPay = true;
        }
    }
    handleChange(event){
        console.log(event.target.value);
        console.log(event.target.name);
        console.log(event.target.type);
        console.log(event.target.label);
        const inputName= event.target.name;
        let value = Number(event.target.value);
        if(inputName === 'basePay'){
            this.baseTakeHomePay = value;
        } 
    }
}