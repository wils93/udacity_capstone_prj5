<script>
    import { BarLoader } from "svelte-loading-spinners";

    let task = {};
    let loading = false;
    let disableButton = false;
    async function getTask() {
        const res = await fetch("https://www.boredapi.com/api/activity");
        const json = await res.json();
        task = json;
        console.log(json);
    }

    async function handleClick() {
        disableButton = loading = true;
        await getTask();
        disableButton = loading = false;
    }
</script>

<main>
    <p style="text-align: center;">
        <strong>D</strong>on't <strong>G</strong>et <strong>B</strong>ored
        <strong>W</strong>ith <strong>M</strong>e (DGBWM)
    </p>

    <p class="click-button-msg">
        To find an interesting thing to do, click the button 👇
    </p>

    <button on:click={handleClick} disabled={disableButton}> Click Me! </button>

    {#if loading}
        <BarLoader size="60" color="#FF3E00" unit="px" duration="1s" />
    {/if}

    {#if !(Object.keys(task).length === 0 && task.constructor === Object)}
        <h4>
            Activity to do 🡢 {task.activity}
        </h4>
        <h4>
            Type of activity 🡢 {task.type}
        </h4>
        <h4>
            # of participants 🡢 {task.participants}
        </h4>
        <h4>
            Accessibility of the task 🡢 {task.accessibility}
        </h4>
    {/if}
</main>

<style>
    @import url("https://fonts.cdnfonts.com/css/bebas-neue");
    @import url("https://fonts.cdnfonts.com/css/old-standard-tt-3");

    main {
        display: grid;
        justify-content: center;
        align-items: center;
        text-align: center;
        background-color: gray;
    }

    .click-button-msg {
        font-family: "Old Standard TT", sans-serif;
        font-size: 1em;
    }

    p {
        font-family: "Bebas Neue", sans-serif;
        font-size: 2em;
    }

    button {
        display: inline-block;
        padding: 0.3em 1.2em;
        margin: 0 0.3em 0.3em 0;
        border-radius: 2em;
        box-sizing: border-box;
        text-decoration: none;
        font-family: "Old Standard TT", sans-serif;
        font-weight: 300;
        color: #ffffff;
        background-color: #4eb5f1;
        text-align: center;
        transition: all 0.2s;
    }

    button:hover {
        background-color: #4095c6;
    }

    h4 {
        font-family: "Bebas Neue", sans-serif;
        text-align: left;
    }
</style>
