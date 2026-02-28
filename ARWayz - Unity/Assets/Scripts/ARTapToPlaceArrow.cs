using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class ARTapToPlaceArrow : MonoBehaviour
{
    [Header("AR Mode (Phone)")]
    [SerializeField] private ARRaycastManager raycastManager;
    [SerializeField] private GameObject arrowPrefab;
    [SerializeField] private bool replaceExistingArrow = true;
    [SerializeField] private bool autoPlaceOnStart = true;
    [SerializeField] private float fallbackDistanceFromCamera = 1.2f;

    [Header("Demo Mode (Editor/Laptop)")]
    [SerializeField] private bool demoModeInEditor = true;
    [SerializeField] private float demoGroundY = 0f;

    [Header("Arrow Visibility")]
    [SerializeField] private bool floatingEffect = true;
    [SerializeField] private float floatAmplitude = 0.05f;
    [SerializeField] private float floatSpeed = 2f;

    [Header("Arrow Orientation")]
    [SerializeField] private Vector3 modelRotationOffsetEuler = new Vector3(0f, 0f, 0f);

    private GameObject spawnedArrow;
    private Vector3 baseArrowPosition;
    private bool didAutoPlace;
    private static readonly List<ARRaycastHit> hits = new List<ARRaycastHit>();

    private void Awake()
    {
        if (raycastManager == null)
        {
            raycastManager = GetComponent<ARRaycastManager>();
        }
    }

    private void Update()
    {
#if UNITY_EDITOR || UNITY_STANDALONE
        if (demoModeInEditor)
        {
            HandleDemoMode();
            return;
        }
#endif
        HandleARMode();
    AnimateArrow();
    }

    private void HandleARMode()
    {
        if (autoPlaceOnStart && !didAutoPlace && spawnedArrow == null && Camera.main != null)
        {
            didAutoPlace = true;
            PlaceArrowInFrontOfCamera();
        }

        if (Input.touchCount == 0) return;

        Touch touch = Input.GetTouch(0);
        if (touch.phase != TouchPhase.Began) return;

        if (raycastManager == null || arrowPrefab == null) return;

        if (raycastManager.Raycast(touch.position, hits, TrackableType.PlaneWithinPolygon | TrackableType.FeaturePoint))
        {
            PlaceArrow(hits[0].pose.position);
            return;
        }

        PlaceArrowInFrontOfCamera();
    }

    private void HandleDemoMode()
    {
        if (!Input.GetMouseButtonDown(0)) return;
        if (Camera.main == null || arrowPrefab == null) return;

        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        Plane groundPlane = new Plane(Vector3.up, new Vector3(0f, demoGroundY, 0f));

        if (groundPlane.Raycast(ray, out float enter))
        {
            Vector3 hitPoint = ray.GetPoint(enter);
            PlaceArrow(hitPoint);
        }
    }

    private void PlaceArrow(Vector3 position)
    {
        Vector3 cameraForward = Camera.main != null ? Camera.main.transform.forward : Vector3.forward;
        Vector3 flatForward = Vector3.ProjectOnPlane(cameraForward, Vector3.up).normalized;
        if (flatForward.sqrMagnitude < 0.001f) flatForward = Vector3.forward;

        Quaternion arrowRotation = Quaternion.LookRotation(flatForward, Vector3.up);

        if (replaceExistingArrow && spawnedArrow != null)
        {
            spawnedArrow.transform.SetPositionAndRotation(position, arrowRotation);
        }
        else
        {
            spawnedArrow = Instantiate(arrowPrefab, position, arrowRotation);
        }

        ApplyModelRotationOffset();

        baseArrowPosition = spawnedArrow.transform.position;
    }

    private void PlaceArrowInFrontOfCamera()
    {
        if (Camera.main == null || arrowPrefab == null) return;

        Vector3 cameraPosition = Camera.main.transform.position;
        Vector3 cameraForward = Camera.main.transform.forward;
        Vector3 fallbackPosition = cameraPosition + cameraForward * fallbackDistanceFromCamera;
        PlaceArrow(fallbackPosition);
    }

    private void AnimateArrow()
    {
        if (!floatingEffect || spawnedArrow == null) return;

        Vector3 animatedPosition = baseArrowPosition;
        animatedPosition.y += Mathf.Sin(Time.time * floatSpeed) * floatAmplitude;
        spawnedArrow.transform.position = animatedPosition;
    }

    private void ApplyModelRotationOffset()
    {
        if (spawnedArrow == null) return;

        spawnedArrow.transform.rotation = spawnedArrow.transform.rotation * Quaternion.Euler(modelRotationOffsetEuler);
    }
}