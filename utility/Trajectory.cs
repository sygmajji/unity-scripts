/***********************************************************************
	filename: 	Trajectory.cs
	created:	06/09/2014
	author:		Charles Mattei
	
	purpose:	Helper class to calculate trajectories.
	
*************************************************************************/

using UnityEngine;
using System.Collections;

//! Trajectory
/*! 
 * Helper class to calculate trajectories.
 * Need origin point and target point.
 * Can specify a vertical offset.
 * Returns a Vector2.
 */
public class Trajectory 
{
	//! Return initial velocity to reach a particular point in 2D
	public static Vector2 GetParableInitialVelocity(Vector3 origin, Vector3 target, float offsetY = 0.0f)
	{
		// Init trajectory variables
		float gravity = Physics2D.gravity.magnitude;
		float height = Mathf.Abs(target.y - origin.y + offsetY);
		float dist = Mathf.Abs(target.x - origin.x);
		
		float vertVelocity = 0.0f;
		float time = 0.0f;
		float horzVelocity = 0.0f;
		
		if (height == 0.0f) height = 0.1f; // Prevents division by zero
		if (gravity == 0.0f) gravity = 0.1f; // Prevents division by zero
		
		// If we are going upward
		// we will use a direct parabolic trajectory 
		// and reach the highest point
		if (target.y - origin.y > 1.0f)
		{
			vertVelocity = Mathf.Sqrt(2.0f * gravity * height);
			time = vertVelocity / gravity;
			horzVelocity = dist / time;
		}
		// If we are going downward
		// we will use a direct parabolic trajectory 
		// with no vertical velocity
		else if (target.y - origin.y < -1.0f)
		{
			vertVelocity = 0.0f;
			time = Mathf.Sqrt(2 * height / gravity);
			horzVelocity = dist / time;
		}
		// Else we will follow a full parabolic trajectory
		// and determine the height of the jump
		// depending on the distance between the 2 points
		else
		{
			height = dist / 4;
			vertVelocity = Mathf.Sqrt(2.0f * gravity * height);
			time = 2 * vertVelocity / gravity;
			horzVelocity = dist / time;
		}
		
		if (vertVelocity == 0.0f && horzVelocity == 0.0f)
		{
			return Vector2.zero;
		}
		
		// Go right
		if (target.x - origin.x > 0 && 
		   !float.IsNaN(vertVelocity) && !float.IsNaN(horzVelocity))
		{
			return new Vector2 (horzVelocity, vertVelocity);
		}
		// Go left
		else if (!float.IsNaN(vertVelocity) && !float.IsNaN(horzVelocity))
		{
			return new Vector2 (-horzVelocity, vertVelocity);
		}
		else 
		{
			return Vector2.zero;
		}
	}
}
