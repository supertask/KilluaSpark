using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Leap;
using Leap.Unity;

namespace Lightning
{
    public class LightningController : MonoBehaviour
    {
        LeapServiceProvider m_Provider;
        Camera camera;
        GameObject originLightningObj;

        // Use this for initialization
        void Start()
        {
            this.m_Provider = GameObject.Find("LeapHandController").GetComponent<LeapServiceProvider>();
            this.camera = GameObject.Find("Main Camera").GetComponent<Camera>();
            this.originLightningObj = GameObject.Find("LightningFinger");
        }

        public static Vector3 ToVector3(Vector v) { return new Vector3(v.x, v.y, v.z); }

        private GameObject CloneLightning(int fingerIndex, Vector3 emitterPos, Vector3 receiverPos) {
            GameObject lightningObj = GameObject.Find("LightningFinger" + fingerIndex);
            if (lightningObj == null) {
                lightningObj = Object.Instantiate(originLightningObj) as GameObject;
                Material mat = Material.Instantiate(originLightningObj.GetComponent<Lightning>()._material);
                lightningObj.name = "LightningFinger" + fingerIndex;
                lightningObj.GetComponent<Lightning>()._material = mat;
            }
            Lightning light = lightningObj.GetComponent<Lightning>();
            light.transform.position = Vector3.Lerp(emitterPos, receiverPos, 0.5f);
            light.emitter = emitterPos;
            light.receiver = receiverPos;
            light._Seed = 2 * fingerIndex * fingerIndex + 3 * fingerIndex + 8;
            return lightningObj;
        }
        private void DeleteLightning(int fingerIndex) {
            GameObject.Destroy(GameObject.Find("LightningFinger" + fingerIndex));
        }

        // Update is called once per frame
        void Update()
        {
            //Debug.Log(this.camera.transform.forward);
            //Debug.Log(this.camera.transform.up);
            Frame frame = this.m_Provider.CurrentFrame;
            if (frame.Hands.Count < 2) {
                return;
            }

            Hand leftHand = frame.Hands[0].IsLeft ? frame.Hands[0] : frame.Hands[1];
            Hand rightHand = frame.Hands[1].IsRight ? frame.Hands[1] : frame.Hands[0];
            for (int i = 0; i < 5; i++) {
                if (leftHand.Fingers[i].IsExtended && rightHand.Fingers[i].IsExtended) {
                    //光らせる
                    Vector3 emitterPos = LightningController.ToVector3(leftHand.Fingers[i].TipPosition);
                    Vector3 receiverPos = LightningController.ToVector3(rightHand.Fingers[i].TipPosition);
                    this.CloneLightning(i, emitterPos, receiverPos);
                }
                else {
                    //光を消す
                    this.DeleteLightning(i);
                }
            }

            /*
            foreach (Hand hand in frame.Hands) {
                Vector3 leapPosition = LightningController.ToVector3(hand.PalmPosition);
                Vector3 leapVelocity = LightningController.ToVector3(hand.PalmVelocity);
                //Debug.Log("actual pos: " + leapPosition);
                //Debug.Log("actual velocity: " + leapVelocity.normalized);

                foreach(Finger finger in hand.Fingers) {
                    //Debug.DrawRay(finger.TipPosition, finger.Direction, Color.red);
                    //Debug.Log("pos: " + finger.TipPosition);
                    Debug.Log("dir: " + finger.Direction);
                }
            }
            */
        }
    }
}