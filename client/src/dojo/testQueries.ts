import { request, gql } from 'graphql-request';

export async function getGameTrackerEntity() {
  const query = gql`
    query getEntities {
      entities(keys: ["0x1"]) {
        edges {
          node {
            keys
            models {
              __typename
              ... on GameTracker {
                count
              }
            }
          }
        }
      }
    }
  `;

  const endpoint = 'https://api.cartridge.gg/x/risingrevenant/torii/graphql'; 
  // const endpoint = 'http://127.0.0.1:8080/graphql';


  try {
    const data: any = await request(endpoint, query);

    const gameTrackerCount: number | undefined = data!.entities.edges
    .find(edge => edge.node.models.some((model: any) => model.__typename === "GameTracker"))
    ?.node.models.find((model: any) => model.__typename === "GameTracker")?.count;

    return gameTrackerCount;

  } catch (error) {
    console.error('Error executing GraphQL query:', error);
    throw error;
  }
}

