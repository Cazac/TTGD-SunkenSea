Shader "Custom/Basic_Hide"
{
	SubShader
	{
		//Render Nothing (Switch To Render Everything????)
		Zwrite off
		ColorMask 0
		Cull off

		Stencil
		{
			//Will always pass ???
			Ref 1
			Comp always
			Pass replace
		}

		//Do Nothing On Pass
		Pass { }
	}
}