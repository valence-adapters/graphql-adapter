/**
 * Encapsulates working with a single GraphQL argument and making it editable with the appropriate form elements.
 */

import {api, LightningElement} from 'lwc';

export default class GraphQLArgumentEditor extends LightningElement {

	@api argument;

	addValue(evt) {
		const newValues = [...this.argument.value] || [];
		newValues.push('<none>'); // add an empty value
		this.emitUpdate(newValues);
	}

	updateValue(evt) {
		console.log('arg got update from child: ', JSON.parse(JSON.stringify(evt.detail)));
		if(this.argument.isList) {
			const index = parseInt(evt.target.dataset.index);
			let newValues;
			console.log('index: ', index);
			if(index !== undefined) { // update to an existing item
				newValues = [...this.argument.value];
				newValues[index] = evt.detail;
			} else { // new item
				newValues = [...this.argument.value] || [];
				newValues.push(evt.detail);
			}
			this.emitUpdate(newValues);
		} else {
			this.emitUpdate(evt.detail);
		}
	}

	emitUpdate(newValue) {
		this.dispatchEvent(new CustomEvent('updateargument', {
			detail : {
				name : this.argument.name,
				fullType : this.argument.fullType,
				value : newValue
			}
		}));
	}

	deleteValue(evt) {
		if(this.argument.isList) {
			const index = parseInt(evt.target.dataset.index);
			const newValues = [...this.argument.value];
			newValues.splice(index, 1);
			if(newValues.length === 0) { // if this was the last item, delete the argument entirely
				this.emitDelete();
			} else {
				this.emitUpdate(newValues);
			}
		} else {
			this.emitDelete();
		}
	}

	emitDelete() {
		this.dispatchEvent(new CustomEvent('deleteargument', {detail : this.argument.name}));
	}
}