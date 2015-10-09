/***********************************************************************
	filename: 	PopupPropertyDrawer.cs
	created:	10/07/2014
	author:		Charles Mattei
	
	purpose:	Expose a string popup choice in the editor.
*************************************************************************/

using UnityEngine;
using UnityEditor; // Editor directory
using System.Collections;
using System;

//! PopupPropertyDrawer
/*! 
 * Custom property drawer for PopupAttribute.
 * Expose a string popup choice in the editor.
 */
[CustomPropertyDrawer(typeof(PopupAttribute))]
public class PopupPropertyDrawer : PropertyDrawer {

	private PopupAttribute popupAttr /*!< Access the property easily. */
	{ 
		get { return ((PopupAttribute)attribute); } 
	}

	//! Draw the property in a popup
	public override void OnGUI (Rect position, SerializedProperty property, GUIContent label) 
	{
		// Retrieve current string
		string current = "";
		if (property.propertyType == SerializedPropertyType.String)
			current = property.stringValue.ToString();
		else 
			return;

		// Find index of the string
		int stringIndex = Array.FindIndex(popupAttr.options, x => x.Contains(current));

		// Force index to zero if we could not find the current string in the options
		if (stringIndex == -1)
		{
			stringIndex = 0;
			Debug.LogError("[PopupPropertyDrawer] Warning : Could not find the property string " + property.stringValue + " in the options.");
		}

		// Draw the popup
		int index = EditorGUI.Popup(position, 
	                           		popupAttr.label,
	                            		stringIndex, 
		                            	popupAttr.options);

		// Save the new index in the attribute
		property.stringValue = popupAttr.options[index];
	}
}
