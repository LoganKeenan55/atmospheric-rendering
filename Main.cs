using Godot;
using System;

public partial class Main : Node3D
{
	private Camera3D camera;
	private WorldEnvironment worldEnvironment;

	public override void _Ready(){
		camera = GetNode<Camera3D>("Camera");
		worldEnvironment = GetNode<WorldEnvironment>("WorldEnvironment");


	}

	public override void _Process(double delta){
		setSkyUniforms();
	}


	public void setSkyUniforms()
	{
		Sky skyResource = worldEnvironment.Environment.Sky;

		if(skyResource?.SkyMaterial is ShaderMaterial skyMat){
			skyMat.SetShaderParameter("cameraPosition",camera.GlobalPosition);
		}
	}
}
