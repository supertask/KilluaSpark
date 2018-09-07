using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Lightning
{
	//[ExecuteInEditMode]
	public class Spark : MonoBehaviour
	{

		[Range(2, 50)]
		public int vertexNum = 4;
		public Material _material;

        [SerializeField] public LightningMesh _mesh;
		[SerializeField] public float _pulseInterval = 0.2f;
		[SerializeField] public float _boltLength = 0.85f;
		[SerializeField] public float _lengthRandomness = 0.8f;
		[SerializeField] public float _noiseFrequency = 0.1f;
		[SerializeField] public float _noiseMotion = 0.1f;
		[SerializeField] public float _noiseAmplitude = 1.2f;

		[SerializeField] public Vector3 p0 = new Vector3(-50, 0, 0);
		[SerializeField] public Vector3 p1 = new Vector3(50, 0, 0);

		//void OnRenderObject()
		void Update()
		{
			_material.SetVector("_Point0", p0);
            _material.SetVector("_Point1", p1);
            _material.SetFloat("_Distance", (p1 - p0).magnitude);

			// make orthogonal axes
            var v0 = (p1 - p0).normalized;
            var v0s = Mathf.Abs(v0.y) > 0.707f ? Vector3.right : Vector3.up;
            var v1 = Vector3.Cross(v0, v0s).normalized;
            var v2 = Vector3.Cross(v0, v1);
            _material.SetVector("_Axis0", v0);
            _material.SetVector("_Axis1", v1);
            _material.SetVector("_Axis2", v2);

			_material.SetVector("_NoiseFrequency", new Vector2(1, 10) * _noiseFrequency);
			_material.SetVector("_NoiseMotion", new Vector2(1, 10) * _noiseMotion);
			_material.SetVector("_NoiseAmplitude", new Vector2(1, 0.1f) * _noiseAmplitude);

			_material.SetVector("_Interval", new Vector2(0.01f, _pulseInterval - 0.01f));

            //lightningの長さはある程度長い方がキルアのに近く
            //_material.SetVector("_Length", new Vector2(1 - _lengthRandomness, 10) * _boltLength);
			_material.SetVector("_Length", new Vector2(3 - _lengthRandomness, 10) * _boltLength);
			_material.SetInt("_VertexNum", vertexNum - 1);
			_material.SetPass(0);
            
			//Graphics.DrawProcedural(MeshTopology.LineStrip, vertexNum);

			// draw lines
            var _materialProps = new MaterialPropertyBlock();
            Graphics.DrawMesh(_mesh.sharedMesh, transform.localToWorldMatrix,
				_material, 0, null, 0, _materialProps);
		}
	}
}