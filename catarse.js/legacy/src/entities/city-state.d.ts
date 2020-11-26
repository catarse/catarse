import { City } from "./city";
import { State } from "./state";

export type CityState = {
    city?: City
    state: {
        acronym: string;
        state_name: string;
    }
}