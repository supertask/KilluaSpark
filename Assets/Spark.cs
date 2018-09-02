using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Spark : MonoBehaviour {
	[Range(2,50)]
    public int vertexNum = 4; 
	public Material material;

    private void OnRenderObject() {
        material.SetInt("_VertexNum", vertexNum - 1);
		material.SetPass(0);
		Graphics.DrawProcedural(MeshTopology.LineStrip, vertexNum);
    }
}
