#!/bin/bash
#ID_TOKEN=$(curl --silent -H "Authorization: bearer ${INPUT_ACTIONS_ID_TOKEN_REQUEST_TOKEN}" -H "Accept: application/json; api-version=2.0" -H "Content-Type: application/json" -d "{}" "${INPUT_ACTIONS_ID_TOKEN_REQUEST_URL}" | jq -r '.value')
ID_TOKEN="${OIDC_TOKEN}"
echo "DECODED ID TOKES IS: "$ID_TOKEN | base64
# Construct JSON payload
REQUEST_BODY=$(jq \
--null-input \
--arg project_name "${GITHUB_REPOSITORY}" \
--arg github_actions_token "${ID_TOKEN}" \
--arg git_sha "${GITHUB_SHA}" \
--arg git_branch "${GITHUB_REF_NAME}" \
--arg owner "${GITHUB_ACTOR}" \
--argjson project_owners '["'${GITHUB_REPOSITORY_OWNER}'"]' \
--arg deployment_type "${DEPLOYMENT_TYPE}" \
--arg factory_cluster "${FACTORY_CLUSTER}" \
'{
    "project_metadata": {"name": $project_name, $github_actions_token, $git_sha, $git_branch, $owner, $project_owners},
    "deployment_metadata": {$deployment_type, $factory_cluster}
}')

#print REQUEST_BODY
echo "print REQUEST_BODY" $REQUEST_BODY

#runs Pokemon test
api_url="https://pokeapi.co/api/v2/pokemon/${INPUT_POKEMON_ID}"
echo $api_url
pokemon_name=$(curl "${api_url}" | jq ".name")
echo "Pokemon: "$pokemon_name

#sets output 
echo "::set-output name=response::$pokemon_name"

# Invoke endpoint
# curl -k \
# -H 'Accept: application/json' \
# -H 'Content-Type: application/json' \
# -d "${REQUEST_BODY}" \
# --fail \
# ${DEPLOYMENT_API_ENDPOINT}/deploy