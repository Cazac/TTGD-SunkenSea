using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SS_BobbingShip : MonoBehaviour
{
    ////////////////////////////////

    public GameObject ship_GO;

    public bool isGoingUp;
    public float maxHeight;
    public float minHeight;

    public float speed;

    ///////////////////////////////////////////////////////

    private void Update()
    {
        
        if (isGoingUp)
        {
            //Go to Max Height
            float newY = Mathf.Lerp(ship_GO.transform.position.y, maxHeight, Time.deltaTime * speed);

            //Set New Position
            ship_GO.transform.position = new Vector3(ship_GO.transform.position.x, newY, ship_GO.transform.position.z);

            //Flip Direction If Needed
            //if (ship_GO.transform.position.y > maxHeight || (ship_GO.transform.position.y - maxHeight) <= 0.25f)
            {
               // print("Switch To Down");
               // isGoingUp = false;
            }

            //Flip Direction If Needed
            if (ship_GO.transform.position.y > (maxHeight / 2))
            {
                print("Switch To Down");
                isGoingUp = false;
            }
        }
        else
        {
            //Go To Min Height
            float newY = Mathf.Lerp(ship_GO.transform.position.y, minHeight, Time.deltaTime * speed);

            //Set New Position
            ship_GO.transform.position = new Vector3(ship_GO.transform.position.x, newY, ship_GO.transform.position.z);

            //Flip Direction If Needed
            //if (ship_GO.transform.position.y < minHeight || (ship_GO.transform.position.y - minHeight) <= 0.25f)
            {
               // print("Switch To Up");
                //isGoingUp = true;
            }

            //Flip Direction If Needed
            if (ship_GO.transform.position.y < ( minHeight / 2))
            {
                print("Switch To Up");
                isGoingUp = true;
            }
        }
    }

    ///////////////////////////////////////////////////////
}
