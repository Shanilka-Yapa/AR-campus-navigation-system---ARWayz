using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class ARArrowController : MonoBehaviour
{
    public ARRaycastManager raycastManager;
    public ARPlaneManager planeManager;
    public GameObject arrowPrefab;

    private GameObject arrowInstance;
    private Transform targetAnchor;
    static List<ARRaycastHit> hits = new List<ARRaycastHit>();

    void Start()
    {
        arrowInstance = Instantiate(arrowPrefab);
        arrowInstance.SetActive(false);
    }

    void Update()
    {
        if (targetAnchor == null)
        {
            if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
            {
                if (raycastManager.Raycast(Input.GetTouch(0).position, hits, TrackableType.PlaneWithinPolygon))
                {
                    Pose hitPose = hits[0].pose;
                    var anchorObj = new GameObject("TargetAnchor");
                    anchorObj.transform.SetPositionAndRotation(hitPose.position, hitPose.rotation);
                    targetAnchor = anchorObj.transform;
                    arrowInstance.SetActive(true);
                }
            }
            return;
        }

        var cam = Camera.main.transform;
        Vector3 arrowPos = cam.position + cam.forward * 0.7f;
        arrowInstance.transform.position = Vector3.Lerp(arrowInstance.transform.position, arrowPos, 0.2f);

        Vector3 dir = (targetAnchor.position - arrowInstance.transform.position);
        dir.y = 0;
        if (dir.sqrMagnitude > 0.001f)
        {
            Quaternion lookRot = Quaternion.LookRotation(dir.normalized, Vector3.up);
            arrowInstance.transform.rotation = Quaternion.Slerp(arrowInstance.transform.rotation, lookRot, 0.2f);
        }
    }
}