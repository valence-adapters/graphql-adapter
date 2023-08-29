/**
 * Allows users to manually key in input values for GraphQL queries that have arguments.
 */

import {api, track, LightningElement} from 'lwc';
import fetchQueryArgumentDefinitions from '@salesforce/apex/GraphQLAdapter.fetchQueryArgumentDefinitions';

export default class GraphQLAdapterSourceConfigurator extends LightningElement {

	definitionsLoaded = false;
	@track definitions = []; // arguments that are possible to set on this query
	required; // track which fields are required

	@api isValid = false;
	@api isDirty = false;

	configurationLoaded = false;
	_original = {};
	_configuration = {};

	get configuration() {
		return this._configuration;
	}

	@api set configuration(newConfig) {
		this.configurationLoaded = true;
		const config = Object.assign({arguments : []}, newConfig);
		this._original = JSON.parse(JSON.stringify(config));
		this._configuration = JSON.parse(JSON.stringify(config));
		this.attemptMerge();
	}

	_link = {};

	get link() {
		return this._link;
	}

	@api set link(linkDetails) {
		this._link = linkDetails;

		console.log('query args for ' + linkDetails.name);
		fetchQueryArgumentDefinitions({'linkName' : linkDetails.name}).then(result => {
			console.log('results: ', result);
			this.definitionsLoaded = true;
			this.definitions = result;
			this.required = new Set();
			this.definitions.forEach(definition => {
				if(definition.isRequired) {
					this.required.add(definition.name);
				}
				if(Array.isArray(definition.enumValues)) { // convert to combobox-friendly
					definition.enumValues = definition.enumValues.map(value => {
						return {value : value, label : value};
					});
				}
			});
			this.attemptMerge();
		}).catch(error => console.error(error));
	}

	get noDefinitionsAvailable() {
		return this.definitionsLoaded && this.definitions.length === 0;
	}

	/**
	 * Our definitions give us the shape of each possible argument, and our configuration has the currently-configured values.
	 *
	 * We combine these together for ease-of-use when passing data down to the child components that help build the form elements
	 */
	attemptMerge() {
		if(this.configurationLoaded && this.definitionsLoaded) {
			console.log('definitionsBeforeMerge: ', JSON.parse(JSON.stringify(this.definitions)));
			this.definitions.forEach(definition => {
				delete definition.value; // clear out all the values so we can load them fresh from the config
				this._configuration.arguments.forEach(configArg => {
					if(definition.name === configArg.name) {
						definition.value = configArg.value;
					}
				});
				if(definition.value === undefined && definition.isList) {
					definition.value = [];
				}
			});
			console.log('definitionsAfterMerge: ', JSON.parse(JSON.stringify(this.definitions)));
			this.definitions = [...this.definitions]; // force refresh because LWC doesn't notice we changed internal properties
		}
	}

	computeDirty() {
		return JSON.stringify(this._original) === JSON.stringify(this._configuration);
	}

	computeValid() {
		/*
		 * Check to make sure all the required fields are configured in our arguments list.
		 */
		let fieldsToCheck = new Set(this.required);
		this._configuration.arguments.forEach(argument => {
			fieldsToCheck.delete(argument.name);
		});
		return fieldsToCheck.size === 0;
	}

	updateConfig() {
		this.dispatchEvent(new CustomEvent('updateconfig', {detail : {newValue : this.configuration}}));
		this.dispatchEvent(new CustomEvent('updatevalid', {detail : {newValue : this.computeValid()}}));
		this.dispatchEvent(new CustomEvent('updatedirty', {detail : {newValue : this.computeDirty()}}));
	}

	updateArgument(evt) {
		const arg = evt.detail;
		console.log('updating args: ', JSON.parse(JSON.stringify(this._configuration)));
		console.log('with: ', JSON.parse(JSON.stringify(arg)));
		let existingFound = false;
		this._configuration.arguments.forEach(argument => {
			if(argument.name === arg.name) {
				existingFound = true;
				argument.value = arg.value;
			}
		});
		if(!existingFound) { // if we didn't update a value, add the entire argument
			this._configuration.arguments.push(arg);
		}
		console.log('after update: ', JSON.parse(JSON.stringify(this._configuration)));
		this.attemptMerge();
		this.updateConfig();
	}

	deleteArgument(evt) {
		const argName = evt.detail;
		// find and delete the correct argument from our list
		const index = this._configuration.arguments.findIndex(argument => argument.name === argName);
		if(index > -1) {
			this._configuration.arguments.splice(index, 1);
		}
		this.attemptMerge();
		this.updateConfig();
	}
}