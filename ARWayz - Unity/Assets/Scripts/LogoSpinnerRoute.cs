using UnityEngine;

public class LogoSpinnerRotate : MonoBehaviour
{
    [SerializeField] private float speed = 20f;
    [SerializeField] private Vector3 axis = Vector3.up;

    void Update()
    {
        transform.Rotate(axis, speed * Time.deltaTime, Space.Self);
    }
}