//libs

//styles
import PageTitleElement from "../Elements/pageTitleElement"
import "./PagesStyles/TradesPageStyles.css"

//elements/components

//pages

/*notes
 this will be a query system but it wont be a query of the saved components instead it will be straight from the graphql return as its done in beer baroon, this is 
 to save on a little of space 
*/


export const TradesPage = () => {
    return (
        <div className="game-page-container">

            <img className="page-img" src="./assets/Page_Bg/TRADES_PAGE_BG.png" alt="testPic" />
            <PageTitleElement name={"TRADES"} rightPicture={"close_icon.svg"} closeFunction={() => { }} ></PageTitleElement>
            
        </div>
    )
}
