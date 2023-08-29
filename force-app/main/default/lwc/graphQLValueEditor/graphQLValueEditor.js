/**
 * Encapsulates editing a single value, knows how to render the correct input elements based on the data type.
 */

import {api, LightningElement} from 'lwc';

export default class GraphQLValueEditor extends LightningElement {

	numericTypes = new Set(['Int']);

	@api name;
	@api defaultValue;
	@api simpleType;
	@api isRequired;
	@api isEnum;
	@api enumValues;

	_value;

	get value() {
		return this._value;
	}

	@api set value(newVal) {
		this._value = newVal === '<none>' ? null : newVal;
	}

	updateValue(evt) {
		this.dispatchEvent(new CustomEvent('updatevalue', {
			detail : this.isBoolean ? evt.target.checked : evt.target.value
		}));
	}

	deleteValue(evt) {
		this.dispatchEvent(new CustomEvent('deletevalue'));
	}

	get isBoolean() {
		return this.simpleType === 'Boolean';
	}

	get isFloat() {
		return this.simpleType === 'Float';
	}

	get isInteger() {
		return this.simpleType === 'Int';
	}

	get isDate() {
		return this.simpleType === 'Date';
	}

	get isString() {
		return this.simpleType === 'String' || this.simpleType === 'ID';
	}
}