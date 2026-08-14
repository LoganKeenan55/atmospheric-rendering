using Godot;
using System;
using System.Numerics;

public partial class Main : Node3D
{
	private Camera3D camera;
	private WorldEnvironment worldEnvironment;
	private DirectionalLight3D sun;
	private Godot.Vector3 sunDir = new Godot.Vector3(0.0f,0.0f,0.0f); //for straight up (0.0f,1.0f,0.0f);

	private float sunSpeed = .5f;
	private float angle = 45.0f;

	public override void _Ready(){
		camera = GetNode<Camera3D>("Camera");
		worldEnvironment = GetNode<WorldEnvironment>("WorldEnvironment");
		sun = GetNode<DirectionalLight3D>("Sun");

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
		sunDir.Z = 0.0f;
		sunDir = sunDir.Normalized();
		setSkyUniforms();

		sun.LookAt(sun.GlobalPosition - sunDir, Godot.Vector3.Up);
		if(sunDir.Y < 0.0f){
			sun.Visible = false;
		}
		else{
			sun.Visible = true;
		}
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
