using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SS_LadderCollider : MonoBehaviour
{

    private void OnTriggerStay(Collider collider)
    {
        //Get Possible Player
        SS_Player playerCollided = collider.gameObject.GetComponent<SS_Player>();

        //Check Player Connection
        if (playerCollided != null)
        {
            //Check For Active player
            if (playerCollided == SS_PlayerMovement.Instance.currentPlayer)
            {
                if (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.S))
                {
                    //Connect To Ladder
                    playerCollided.ConnectToLadder(gameObject);
                }
            }
        }
    }

    private void OnTriggerExit(Collider collider)
    {
        //Get Possible Player
        SS_Player playerCollided = collider.gameObject.GetComponent<SS_Player>();


        //Connect To Ladder
        playerCollided.CappedLadder();

    }

}
