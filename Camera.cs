using Godot;
using System;
using System.Runtime.InteropServices.Marshalling;

public partial class Camera : Camera3D
{
	Vector3 velocity = Vector3.Zero;
	Vector2 lookAngles = Vector2.Zero;

	[Export]
	private float acceleration = 2500.0f;
	private float moveSpeed = 2000.0f;
	private float mouseSpeed = 300.0f;

	public override void _Ready(){
		Input.MouseMode = Input.MouseModeEnum.Captured;

	}

	public override void _Process(double delta){
		lookAngles.Y = (float)Math.Clamp(lookAngles.Y, Math.PI / -2, Math.PI / 2);
		Rotation = new Vector3(lookAngles.Y,lookAngles.X,0);
		Vector3 direction = updateDirection(delta);
		if(direction.LengthSquared() > 0){
			velocity += direction * acceleration * (float)delta;
		}
		if(velocity.Length() > moveSpeed){
			velocity = velocity.Normalized() * moveSpeed;
		}

		Translate(velocity * (float)delta);
	}

    public override void _Input(InputEvent @event){
        base._Input(@event);
		if(@event is InputEventMouseMotion mouseMotion){
			lookAngles -= mouseMotion.Relative / mouseSpeed;
		}

    }

	Vector3 updateDirection(double delta){
		Vector3 direction = new Vector3();
		if (Input.IsActionPressed("w")){
			direction += Vector3.Forward;
		}
		if (Input.IsActionPressed("a")){
			direction += Vector3.Left;
		}
		if (Input.IsActionPressed("s")){
			direction += Vector3.Back;
		}
		if (Input.IsActionPressed("d")){
			direction += Vector3.Right;
		}
		if (Input.IsActionPressed("space")){
			GlobalPosition += new Vector3(0, moveSpeed * (float)delta, 0);
		}
		if (Input.IsActionPressed("ctrl")){
			GlobalPosition -= new Vector3(0, moveSpeed * (float)delta, 0);
		}
		if(direction == Vector3.Zero){
			velocity = Vector3.Zero;
		}
		if (Input.IsActionJustPressed("esc")){
			GetTree().Quit();
		}
		return direction.Normalized();
	}

}
