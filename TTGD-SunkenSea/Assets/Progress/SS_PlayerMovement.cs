using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SS_PlayerMovement : MonoBehaviour
{
    ////////////////////////////////

    public static SS_PlayerMovement Instance;

    ////////////////////////////////

    public SS_Player playerA;
    public SS_Player playerB;

    public SS_Player currentPlayer;


    public GameObject mainCamera;


    ///////////////////////////////////////////////////////

    private void Awake()
    {
        //Set Static Singleton Self Refference
        Instance = this;

        //Set Default Player
        currentPlayer = playerA;
    }


    private void Update()
    {
        LookForKey_SwitchPlayers();




        currentPlayer.TakePlayerInput();

        if (playerA != currentPlayer)
        {
            playerA.TakeAIInput();
        }
        else if (playerB != currentPlayer)
        {
            playerB.TakeAIInput();
        }


        CameraFollowPlayer();
    }

    ///////////////////////////////////////////////////////

    private void CameraFollowPlayer()
    {

        Vector3 newPosition = currentPlayer.transform.position;

        newPosition = new Vector3(newPosition.x, newPosition.y + 3, newPosition.z + -20);

        mainCamera.transform.position = newPosition;
    }



    private void LookForKey_SwitchPlayers()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            if (currentPlayer == playerB)
            {
                currentPlayer = playerA;
            }
            else if (currentPlayer == playerA)
            {
                currentPlayer = playerB;
            }
        }
    }


    ///////////////////////////////////////////////////////
}
