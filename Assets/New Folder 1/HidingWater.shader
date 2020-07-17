Shader "Custom/HidingWater"
{
	SubShader
	{
		//Render Nothing (Switch To reder everything????)
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


		Pass 
		{

		}
	}
}