using Godot;
using System;
using System.Numerics;

public partial class Main : Node3D
{
	private Camera3D camera;
	private WorldEnvironment worldEnvironment;
	private Godot.Vector3 sunDir = new Godot.Vector3(0.0f,0.0f,0.0f); //for straight up (0.0f,1.0f,0.0f);

	private float sunSpeed = .5f;
	private float angle = 0.0f;

	public override void _Ready(){
		camera = GetNode<Camera3D>("Camera");
		worldEnvironment = GetNode<WorldEnvironment>("WorldEnvironment");


	}

	public override void _Process(double delta){
		if (Input.IsActionPressed("e")){
			angle += sunSpeed * (float)delta;
		}
		if (Input.IsActionPressed("q")){
			angle -= sunSpeed * (float)delta;
		}
		sunDir.X = Mathf.Sin(angle);
		sunDir.Y = MathF.Cos(angle);
		setSkyUniforms();
	}


	public void setSkyUniforms()
	{
		Sky skyResource = worldEnvironment.Environment.Sky;

		if(skyResource?.SkyMaterial is ShaderMaterial skyMat){
			skyMat.SetShaderParameter("cameraPosition", camera.GlobalPosition);
			skyMat.SetShaderParameter("sunDirection", sunDir.Normalized());
		}
	}
}
